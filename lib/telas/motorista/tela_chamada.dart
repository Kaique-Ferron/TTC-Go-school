import 'package:flutter/material.dart';
import '../../models/crianca_rota.dart';
import '../../models/feriado.dart';
import '../../services/auth_service.dart';
import '../../services/feriados_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import '../../widgets/shell_motorista.dart';

class TelaChamada extends StatefulWidget {
  const TelaChamada({super.key});

  @override
  State<TelaChamada> createState() => _TelaChamadaState();
}

class _TelaChamadaState extends State<TelaChamada> {
  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  String _periodo = DateTime.now().hour < 12 ? 'Manhã' : 'Tarde';
  String _meuNome = '';
  bool _marcandoTodos = false;
  final _hoje = DateTime.now();

  Feriado? _feriadoHoje;

  String get _dataFormatada => '${_hoje.day} de ${_meses[_hoje.month - 1]}';

  @override
  void initState() {
    super.initState();
    final uid = AuthService.instance.uidAtual;
    if (uid != null) {
      FirestoreService.instance.usuarioStream(uid).first.then((usuario) {
        if (mounted) setState(() => _meuNome = usuario?.nome ?? '');
      });
    }
    _verificarFeriado();
  }

  Future<void> _verificarFeriado() async {
    final feriado = await FeriadosService.instance.feriadoDeHoje();
    if (!mounted) return;
    setState(() => _feriadoHoje = feriado);
  }

  Future<void> _marcarTodosPresentes(String uid, String chamadaId, List<CriancaRota> pendentes) async {
    if (pendentes.isEmpty) return;
    setState(() => _marcandoTodos = true);
    try {
      await Future.wait(pendentes.map(
        (crianca) => FirestoreService.instance.marcarPresenca(
          motoristaUid: uid,
          motoristaNome: _meuNome,
          chamadaId: chamadaId,
          periodo: _periodo,
          crianca: crianca,
          presente: true,
        ),
      ));
    } finally {
      if (mounted) setState(() => _marcandoTodos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Utilizador não autenticado.')),
      );
    }

    return ShellMotorista(
      itemSelecionado: 'Chamada',
      builder: (context) => _buildConteudo(context, uid),
    );
  }

  Widget _buildConteudo(BuildContext context, String uid) {
    final chamadaId = FirestoreService.instance.chamadaIdPara(_hoje, _periodo);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chamada de hoje',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
          ),
          const SizedBox(height: 2),
          Text(
            'Confirme quem embarcou na van — $_dataFormatada.',
            style: TextStyle(fontSize: 13, color: AppCores.textoSecundario(context)),
          ),
          const SizedBox(height: 16),
          if (_feriadoHoje != null) ...[
            _buildAviso('📅 Hoje é feriado nacional (${_feriadoHoje!.nome}) — pode não ter aula.'),
            const SizedBox(height: 14),
          ],
          _buildSeletorPeriodo(context),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<CriancaRota>>(
              stream: FirestoreService.instance.criancasDaRotaStream(uid),
              builder: (context, snapshotRota) {
                if (snapshotRota.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todas = snapshotRota.data ?? [];
                final criancas = todas.where((c) => c.periodo == _periodo).toList()
                  ..sort((a, b) => a.nome.compareTo(b.nome));

                if (criancas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(Icons.checklist_outlined, size: 44, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma criança no período "$_periodo".',
                            style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return StreamBuilder<Map<String, dynamic>?>(
                  stream: FirestoreService.instance.chamadaStream(uid, chamadaId),
                  builder: (context, snapshotChamada) {
                    final criancasMarcadas = snapshotChamada.data?['criancas'] as Map<String, dynamic>?;

                    final presentes = <CriancaRota>[];
                    final ausentes = <CriancaRota>[];
                    final pendentes = <CriancaRota>[];
                    for (final crianca in criancas) {
                      final marcacao = criancasMarcadas?[crianca.filhoId] as Map<String, dynamic>?;
                      final presente = marcacao?['presente'] as bool?;
                      if (presente == true) {
                        presentes.add(crianca);
                      } else if (presente == false) {
                        ausentes.add(crianca);
                      } else {
                        pendentes.add(crianca);
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResumo(context, total: criancas.length, presentes: presentes.length, ausentes: ausentes.length, pendentes: pendentes.length),
                        const SizedBox(height: 14),
                        if (pendentes.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _marcandoTodos ? null : () => _marcarTodosPresentes(uid, chamadaId, pendentes),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppCores.verde),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: _marcandoTodos
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppCores.verde))
                                  : const Icon(Icons.done_all, color: AppCores.verde, size: 18),
                              label: Text(
                                'Marcar ${pendentes.length} restante${pendentes.length == 1 ? '' : 's'} como presente${pendentes.length == 1 ? '' : 's'}',
                                style: const TextStyle(color: AppCores.verde, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (pendentes.isNotEmpty) const SizedBox(height: 14),
                        Expanded(
                          child: ListView.separated(
                            itemCount: criancas.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final crianca = criancas[index];
                              final marcacao = criancasMarcadas?[crianca.filhoId] as Map<String, dynamic>?;
                              final presente = marcacao?['presente'] as bool?;

                              return _buildLinhaCrianca(
                                context,
                                crianca: crianca,
                                presente: presente,
                                onMarcar: (valor) => FirestoreService.instance.marcarPresenca(
                                  motoristaUid: uid,
                                  motoristaNome: _meuNome,
                                  chamadaId: chamadaId,
                                  periodo: _periodo,
                                  crianca: crianca,
                                  presente: valor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAviso(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppCores.ambar.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.ambar.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppCores.ambar),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 12, color: AppCores.ambar))),
        ],
      ),
    );
  }

  Widget _buildResumo(BuildContext context, {required int total, required int presentes, required int ausentes, required int pendentes}) {
    final progresso = total == 0 ? 0.0 : (presentes + ausentes) / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$total criança${total == 1 ? '' : 's'} no período',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
              ),
              Text(
                '${(progresso * 100).round()}% concluído',
                style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 6,
              backgroundColor: AppCores.fundo(context),
              valueColor: const AlwaysStoppedAnimation(AppCores.verde),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildContador(context, 'Presentes', presentes, AppCores.verde),
              const SizedBox(width: 16),
              _buildContador(context, 'Ausentes', ausentes, Colors.red),
              const SizedBox(width: 16),
              _buildContador(context, 'Pendentes', pendentes, AppCores.textoSecundario(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContador(BuildContext context, String rotulo, int valor, Color cor) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$valor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppCores.textoPrincipal(context))),
        const SizedBox(width: 4),
        Text(rotulo, style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context))),
      ],
    );
  }

  Widget _buildSeletorPeriodo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppCores.superficie(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppCores.borda(context))),
      child: Row(
        children: ['Manhã', 'Tarde'].map((opcao) {
          final selecionado = opcao == _periodo;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _periodo = opcao),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selecionado ? AppCores.laranjaMotorista : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    opcao,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                      color: selecionado ? Colors.white : AppCores.textoPrincipal(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLinhaCrianca(
    BuildContext context, {
    required CriancaRota crianca,
    required bool? presente,
    required ValueChanged<bool> onMarcar,
  }) {
    final corStatus = presente == true
        ? AppCores.verde
        : presente == false
        ? Colors.red
        : AppCores.textoSecundario(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corStatus.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppCores.laranjaMotorista.withValues(alpha: 0.12),
            child: const Icon(Icons.child_care, color: AppCores.laranjaMotorista, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crianca.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  'Resp.: ${crianca.responsavelNome.isNotEmpty ? crianca.responsavelNome : "—"}',
                  style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onMarcar(true),
            icon: Icon(Icons.check_circle, color: presente == true ? AppCores.verde : Colors.grey.shade400),
            tooltip: 'Presente',
          ),
          IconButton(
            onPressed: () => onMarcar(false),
            icon: Icon(Icons.cancel, color: presente == false ? Colors.red : Colors.grey.shade400),
            tooltip: 'Ausente',
          ),
        ],
      ),
    );
  }
}
