import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../widgets/card_filho.dart';
import '../../widgets/modal_info_filho.dart';
import '../../widgets/nav_inferior_responsavel.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/pulsante.dart';
import '../../theme/cores.dart';
import 'cadastrar_filho_tela.dart';

class MeusFilhosTela extends StatelessWidget {
  const MeusFilhosTela({super.key});

  static const Color azulPrincipal = Color(0xFF1D58E2);

  void _abrirModalDetalhes(BuildContext context, String uid, Filho filho) {
    showDialog(
      context: context,
      builder: (dialogContext) => ModalInfoFilho(
        nome: filho.nome,
        idadeEAno: filho.idadeEAno,
        escola: filho.escola,
        periodo: '${filho.turno} (${filho.horario})',
        tipoSanguineo: filho.tipoSanguineo.isEmpty ? '—' : filho.tipoSanguineo,
        alergias: filho.alergias.isEmpty ? 'Nenhuma' : filho.alergias,
        status: filho.status,
        onEditar: () {
          Navigator.pop(dialogContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastrarFilhoTela(filhoParaEditar: filho),
            ),
          );
        },
        onExcluir: () async {
          Navigator.pop(dialogContext);
          if (filho.id == null) return;
          await FirestoreService.instance.excluirFilho(uid, filho.id!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil do filho removido!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    if (!logado) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: const Text('Sessão expirada. Toque para fazer login novamente.'),
          ),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Meus Filhos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: azulPrincipal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CadastrarFilhoTela(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Meus filhos'),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Meus Filhos'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gerencie as informações dos seus filhos cadastrados.',
              style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Stream em tempo real do Firestore
            StreamBuilder<List<Filho>>(
              stream: FirestoreService.instance.filhosStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar a lista de filhos.'));
                }

                final filhos = snapshot.data ?? [];

                if (filhos.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppCores.azulPrincipal.withValues(alpha: 0.08), AppCores.laranjaClaro.withValues(alpha: 0.06)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppCores.azulPrincipal.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: AppCores.azulPrincipal.withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: const Icon(Icons.child_care, size: 40, color: azulPrincipal),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum filho cadastrado',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cadastre um novo filho para utilizar o serviço de transporte.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filhos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final filho = filhos[index];
                        return _buildCardFilhoCustomizado(context, uid, filho, index);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Botão para Adicionar Filho
                    StreamBuilder<List<Filho>>(
                      stream: FirestoreService.instance.filhosStream(uid),
                      builder: (context, snapshotBotao) {
                        final semFilhos = (snapshotBotao.data ?? []).isEmpty;
                        return Pulsante(
                          ativo: semFilhos,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: azulPrincipal,
                              elevation: 0,
                              shadowColor: azulPrincipal.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CadastrarFilhoTela(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Adicionar filho',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Banner Informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [AppCores.azulPrincipal.withValues(alpha: 0.10), AppCores.ciano.withValues(alpha: 0.10)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppCores.superficie(context),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: azulPrincipal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Importante: mantenha as informações dos seus filhos sempre atualizadas. Isso garante mais segurança no GoSchool.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.3,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue.shade100
                                    : Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFilhoCustomizado(BuildContext context, String uid, Filho filho, int index) {
    final corAcento = AppCores.corFilho(index);
    // Vermelho puro em cima do rosa quase-branco (shade50 a 50% alpha) fica
    // com uma cor estranha e lavada sobre a superfície escura — usa um tom
    // mais claro no escuro e monta o fundo/borda com o mesmo alpha-blend
    // usado no resto do card em vez de um tom sólido fixo.
    final corExcluir = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: corAcento.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(color: corAcento.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Faixa colorida no topo — identifica cada filho de relance,
          // consistente com a cor usada no avatar/ícones do CardFilho.
          Container(height: 5, color: corAcento),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardFilho(
                  nome: filho.nome,
                  idadeEAno: filho.idadeEAno,
                  escola: filho.escola,
                  turno: filho.turno,
                  horario: filho.horario,
                  status: filho.status,
                  corAcento: corAcento,
                  onTap: () => _abrirModalDetalhes(context, uid, filho),
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: corAcento.withValues(alpha: 0.15)),
                const SizedBox(height: 12),

                _buildLinhaInfo(
                  context,
                  Icons.account_balance_outlined,
                  'Escola',
                  filho.escola.isNotEmpty ? filho.escola : 'Não informada',
                  AppCores.azulClaro,
                ),
                const SizedBox(height: 10),
                _buildLinhaInfo(
                  context,
                  Icons.directions_bus_outlined,
                  'Turno / Horário',
                  '${filho.turno} ${filho.horario.isNotEmpty ? "(${filho.horario})" : ""}',
                  AppCores.laranjaMotorista,
                ),
                const SizedBox(height: 10),
                _buildLinhaInfo(
                  context,
                  Icons.bloodtype_outlined,
                  'Tipo Sanguíneo',
                  filho.tipoSanguineo.isNotEmpty ? filho.tipoSanguineo : 'Não informado',
                  AppCores.rosa,
                ),
                const SizedBox(height: 10),
                _buildLinhaInfo(
                  context,
                  Icons.warning_amber_outlined,
                  'Alergias',
                  filho.alergias.isNotEmpty ? filho.alergias : 'Nenhuma cadastrada',
                  AppCores.ambar,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CadastrarFilhoTela(filhoParaEditar: filho),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: corAcento.withValues(alpha: 0.5)),
                          foregroundColor: corAcento,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(Icons.edit_outlined, size: 16, color: corAcento),
                        label: Text(
                          'Editar',
                          style: TextStyle(fontSize: 13, color: corAcento, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _abrirModalDetalhes(context, uid, filho),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: corExcluir.withValues(alpha: 0.5)),
                          backgroundColor: corExcluir.withValues(alpha: 0.10),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(Icons.delete_outline, size: 16, color: corExcluir),
                        label: Text(
                          'Excluir',
                          style: TextStyle(fontSize: 13, color: corExcluir, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaInfo(BuildContext context, IconData icone, String titulo, String valor, Color cor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icone, size: 14, color: cor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context)),
              ),
              Text(
                valor,
                style: TextStyle(fontSize: 13, color: AppCores.textoPrincipal(context), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}