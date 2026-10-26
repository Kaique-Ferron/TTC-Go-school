import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/filho.dart';
import '../../models/motorista_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import '../../widgets/foto_perfil_provider.dart';

/// Tela de contratação de um motorista pelo Responsável: escolhe o período,
/// seleciona quais filhos vão usar o transporte, confere o resumo com o
/// valor total e confirma. Grava a contratação em
/// usuarios/{responsavelUid}/contratacoes (ver firestore/MIGRATIONS.md).
class TelaContratacao extends StatefulWidget {
  final Motorista motorista;

  /// Sobrescritas usadas em testes de widget (injeta um uid e um
  /// FirestoreService fake em vez dos singletons reais). Em produção ficam
  /// nulas e a tela usa AuthService/FirestoreService normalmente.
  @visibleForTesting
  final String? uidParaTeste;
  @visibleForTesting
  final FirestoreService? servicoParaTeste;

  const TelaContratacao({
    super.key,
    required this.motorista,
    this.uidParaTeste,
    this.servicoParaTeste,
  });

  @override
  State<TelaContratacao> createState() => _TelaContratacaoState();
}

class _TelaContratacaoState extends State<TelaContratacao> {
  final Set<String> _filhosSelecionadosIds = {};
  String? _periodo;
  bool _enviando = false;

  bool get _temManha => widget.motorista.criancasManha > 0;
  bool get _temTarde => widget.motorista.criancasTarde > 0;

  String? get _uid => widget.uidParaTeste ?? AuthService.instance.uidAtual;
  FirestoreService get _servico =>
      widget.servicoParaTeste ?? FirestoreService.instance;

  // Criado uma única vez em initState — se fosse recriado a cada build (ex.:
  // ao marcar um filho ou trocar o período), o StreamBuilder reinterpretaria
  // como uma troca de stream e voltaria a exibir o spinner de carregamento
  // a cada toque, descartando a seleção visível momentaneamente.
  Stream<List<Filho>>? _filhosStream;

  @override
  void initState() {
    super.initState();
    final uid = _uid;
    if (uid != null) _filhosStream = _servico.filhosStream(uid);
    // Pré-seleciona o único período disponível, se só tiver um.
    if (_temManha && !_temTarde) {
      _periodo = 'Manhã';
    } else if (_temTarde && !_temManha) {
      _periodo = 'Tarde';
    }
  }

  Future<void> _confirmarContratacao(
    List<Filho> todosOsFilhos,
    String uid,
  ) async {
    if (_periodo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um período (Manhã ou Tarde).')),
      );
      return;
    }
    if (_filhosSelecionadosIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um filho.')),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      final filhosSelecionados = todosOsFilhos
          .where((f) => _filhosSelecionadosIds.contains(f.id))
          .toList();
      final valorTotal =
          widget.motorista.valorMensalidade * filhosSelecionados.length;
      final meuUsuario = await _servico.usuarioStream(uid).first;
      // lat/lng/endereço não fazem parte do model Usuario (são gravados à
      // parte por MapaCasaTela/EditarPerfilTela) — lidos direto do
      // documento aqui, só pra guardar uma cópia na contratação e o
      // Motorista conseguir montar a rota sem precisar ler o documento
      // completo do Responsável (que agora só o dono pode ler).
      final meuDocumento = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      final meusDados = meuDocumento.data();

      await _servico.registrarContratacao(uid, {
        'motoristaUid': widget.motorista.uid,
        'motoristaNome': widget.motorista.nome,
        'motoristaVeiculo': widget.motorista.veiculo,
        'motoristaPlaca': widget.motorista.placa,
        'responsavelNome': meuUsuario?.nome ?? '',
        'responsavelLat': meusDados?['casa_lat'],
        'responsavelLng': meusDados?['casa_lng'],
        'responsavelEndereco': (meusDados?['casa_endereco'] as String?)?.trim().isNotEmpty == true
            ? meusDados!['casa_endereco']
            : (meusDados?['endereco'] as String?) ?? '',
        'filhosIds': filhosSelecionados.map((f) => f.id).toList(),
        'filhosNomes': filhosSelecionados.map((f) => f.nome).toList(),
        'periodo': _periodo,
        'valorPorFilho': widget.motorista.valorMensalidade,
        'valorTotal': valorTotal,
        'status': 'Ativo',
        'contratadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppCores.verde.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppCores.verde,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Contratação confirmada!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.motorista.nome} vai transportar ${filhosSelecionados.length == 1 ? filhosSelecionados.first.nome : '${filhosSelecionados.length} filhos'} no período da $_periodo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCores.azulPrincipal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Entendi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao confirmar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    final m = widget.motorista;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Contratar Motorista'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(child: Text('Utilizador não autenticado.'))
          : StreamBuilder<List<Filho>>(
              stream: _filhosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filhos = snapshot.data ?? [];
                final qtdSelecionados = _filhosSelecionadosIds.length;
                final total = m.valorMensalidade * qtdSelecionados;

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _cardMotorista(m),
                          const SizedBox(height: 24),

                          const Text(
                            '1. Escolha o período',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _chipPeriodo(
                                  titulo: 'Manhã',
                                  icone: Icons.wb_sunny_outlined,
                                  cor: AppCores.ambar,
                                  disponivel: _temManha,
                                  vagas: m.criancasManha,
                                  selecionado: _periodo == 'Manhã',
                                  onTap: () =>
                                      setState(() => _periodo = 'Manhã'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _chipPeriodo(
                                  titulo: 'Tarde',
                                  icone: Icons.nightlight_outlined,
                                  cor: AppCores.roxo,
                                  disponivel: _temTarde,
                                  vagas: m.criancasTarde,
                                  selecionado: _periodo == 'Tarde',
                                  onTap: () =>
                                      setState(() => _periodo = 'Tarde'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            '2. Selecione o(s) filho(s)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (filhos.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.family_restroom,
                                    size: 36,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Cadastre um filho primeiro em "Meus filhos" para poder contratar o transporte.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...filhos.map(
                              (filho) => _cardFilhoSelecionavel(filho),
                            ),
                        ],
                      ),
                    ),

                    // Resumo + confirmar, fixo embaixo
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    qtdSelecionados == 0
                                        ? 'Nenhum filho selecionado'
                                        : '$qtdSelecionados filho${qtdSelecionados == 1 ? '' : 's'} selecionado${qtdSelecionados == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Total: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}/mês',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppCores.verde,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppCores.azulPrincipal,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _enviando
                                    ? null
                                    : () => _confirmarContratacao(filhos, uid),
                                icon: _enviando
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                      ),
                                label: const Text(
                                  'Confirmar contratação',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _cardMotorista(Motorista m) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppCores.azulPrincipal.withValues(alpha: 0.06),
            AppCores.roxo.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE8EEFC),
            backgroundImage: fotoPerfilProvider(m.fotoPerfil),
            child: m.fotoPerfil.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 32,
                    color: AppCores.azulPrincipal,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${m.veiculo} • ${m.placa}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'R\$ ${m.valorMensalidade.toStringAsFixed(2).replaceAll('.', ',')} / mês por filho',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppCores.verde,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipPeriodo({
    required String titulo,
    required IconData icone,
    required Color cor,
    required bool disponivel,
    required int vagas,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: disponivel ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disponivel ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selecionado ? cor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionado ? cor : Colors.grey.shade200,
              width: selecionado ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 22),
              const SizedBox(height: 6),
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: selecionado ? cor : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                disponivel
                    ? '$vagas vaga${vagas == 1 ? '' : 's'}'
                    : 'Sem vagas',
                style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardFilhoSelecionavel(Filho filho) {
    final selecionado = _filhosSelecionadosIds.contains(filho.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selecionado
            ? AppCores.azulPrincipal.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selecionado ? AppCores.azulPrincipal : Colors.grey.shade200,
          width: selecionado ? 1.6 : 1,
        ),
      ),
      // Material(transparent) entre o Container colorido e o CheckboxListTile
      // pra o ink splash do toque pintar por cima da cor de fundo, em vez de
      // ficar invisível atrás dela.
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: CheckboxListTile(
          value: selecionado,
          onChanged: (marcado) {
            setState(() {
              if (marcado == true && filho.id != null) {
                _filhosSelecionadosIds.add(filho.id!);
              } else {
                _filhosSelecionadosIds.remove(filho.id);
              }
            });
          },
          activeColor: AppCores.azulPrincipal,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            filho.nome,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${filho.idadeEAno} • ${filho.escola}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ),
    );
  }
}
