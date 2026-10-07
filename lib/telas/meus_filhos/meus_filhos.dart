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
        backgroundColor: const Color(0xFFF8FAFC),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meus Filhos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            const Text(
              'Gerencie as informações dos seus filhos cadastrados.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.child_care, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhum filho cadastrado',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cadastre um novo filho para utilizar o serviço de transporte.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: azulPrincipal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                            icon: const Icon(Icons.add, color: azulPrincipal),
                            label: const Text(
                              'Adicionar filho',
                              style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold),
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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: azulPrincipal, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Importante: mantenha as informações dos seus filhos sempre atualizadas. Isso garante mais segurança no GoSchool.',
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.3),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
            corAcento: AppCores.corFilho(index),
            onTap: () => _abrirModalDetalhes(context, uid, filho),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          _buildLinhaInfo(
            Icons.account_balance_outlined,
            'Escola',
            filho.escola.isNotEmpty ? filho.escola : 'Não informada',
          ),
          const SizedBox(height: 8),
          _buildLinhaInfo(
            Icons.directions_bus_outlined,
            'Turno / Horário',
            '${filho.turno} ${filho.horario.isNotEmpty ? "(${filho.horario})" : ""}',
          ),
          const SizedBox(height: 8),
          _buildLinhaInfo(
            Icons.bloodtype_outlined,
            'Tipo Sanguíneo',
            filho.tipoSanguineo.isNotEmpty ? filho.tipoSanguineo : 'Não informado',
          ),
          const SizedBox(height: 8),
          _buildLinhaInfo(
            Icons.warning_amber_outlined,
            'Alergias',
            filho.alergias.isNotEmpty ? filho.alergias : 'Nenhuma cadastrada',
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
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.black87),
                  label: const Text(
                    'Editar',
                    style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _abrirModalDetalhes(context, uid, filho),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.red.shade200),
                    backgroundColor: Colors.red.shade50.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text(
                    'Excluir',
                    style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaInfo(IconData icone, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                valor,
                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}