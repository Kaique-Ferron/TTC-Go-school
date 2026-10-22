import 'package:flutter/material.dart';
import '../../models/crianca_rota.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';

/// Chamada do Motorista — confirma, pra cada criança da rota, se ela está
/// (ou não) dentro da van no período selecionado. Grava em
/// usuarios/{motoristaUid}/chamadas/{yyyy-MM-dd}_{periodo} e manda uma
/// mensagem real no chat avisando o responsável a cada confirmação.
class TelaChamada extends StatefulWidget {
  const TelaChamada({super.key});

  @override
  State<TelaChamada> createState() => _TelaChamadaState();
}

class _TelaChamadaState extends State<TelaChamada> {
  String _periodo = DateTime.now().hour < 12 ? 'Manhã' : 'Tarde';
  String _meuNome = '';
  final _hoje = DateTime.now();

  @override
  void initState() {
    super.initState();
    final uid = AuthService.instance.uidAtual;
    if (uid != null) {
      FirestoreService.instance.usuarioStream(uid).first.then((usuario) {
        if (mounted) setState(() => _meuNome = usuario?.nome ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        appBar: AppBar(title: const Text('Chamada')),
        body: const Center(child: Text('Utilizador não autenticado.')),
      );
    }

    final chamadaId = FirestoreService.instance.chamadaIdPara(_hoje, _periodo);

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(title: const Text('Chamada')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirme quem está na van hoje.',
              style: TextStyle(fontSize: 14, color: AppCores.textoSecundario(context)),
            ),
            const SizedBox(height: 16),
            _buildSeletorPeriodo(context),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<CriancaRota>>(
                stream: FirestoreService.instance.criancasDaRotaStream(uid),
                builder: (context, snapshotRota) {
                  if (snapshotRota.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todas = snapshotRota.data ?? [];
                  final criancas = todas.where((c) => c.periodo == _periodo).toList();

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

                      return ListView.separated(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
