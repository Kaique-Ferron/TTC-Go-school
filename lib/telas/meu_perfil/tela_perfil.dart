import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../widgets/card_filho.dart';
import '../../widgets/card_cartao.dart';
import '../../widgets/modal_info_filho.dart';
import '../../widgets/nav_inferior_responsavel.dart';
import 'editar_perfil_tela.dart';

/// Tela de Perfil do Responsável — atualiza em tempo real via StreamBuilder
/// ouvindo diretamente o documento do usuário no Firestore.
class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

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
          Navigator.pushNamed(context, '/meus-filhos');
        },
        onExcluir: () async {
          Navigator.pop(dialogContext);
          if (filho.id == null) return;
          await FirestoreService.instance.excluirFilho(uid, filho.id!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil do filho removido!'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  Future<void> _sair(BuildContext context) async {
    await AuthService.instance.sair();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
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
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Perfil'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados do perfil.'));
          }

          final dados = snapshot.data?.data();
          final nome = (dados?['nome'] as String?)?.trim();
          final telefone = (dados?['telefone'] as String?)?.trim();
          final endereco = (dados?['endereco'] as String?)?.trim();
          final email = (dados?['email'] as String?) ?? FirebaseAuth.instance.currentUser?.email;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gerencie suas informações e preferências.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Card Dados Pessoais
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE8F0FE),
                            child: Icon(Icons.person, size: 48, color: azulPrincipal),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditarPerfilTela(dadosAtuais: dados)),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nome != null && nome.isNotEmpty ? nome : 'Sem nome cadastrado',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                            child: const Text(
                              'Responsável',
                              style: TextStyle(color: azulPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildItemInfo(Icons.email_outlined, email ?? '—'),
                      const SizedBox(height: 8),
                      _buildItemInfo(Icons.phone_outlined, telefone != null && telefone.isNotEmpty ? telefone : 'Não informado'),
                      const SizedBox(height: 8),
                      _buildItemInfo(Icons.location_on_outlined, endereco != null && endereco.isNotEmpty ? endereco : 'Endereço não informado'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card Meus Filhos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Meus filhos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/meus-filhos'),
                            child: const Text('Ver todos', style: TextStyle(color: azulPrincipal)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<List<Filho>>(
                        stream: FirestoreService.instance.filhosStream(uid),
                        builder: (context, snapshotFilhos) {
                          if (snapshotFilhos.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final filhos = snapshotFilhos.data ?? [];
                          if (filhos.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text('Nenhum filho cadastrado ainda.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            );
                          }
                          return Column(
                            children: filhos
                                .take(2)
                                .map(
                                  (filho) => CardFilho(
                                    nome: filho.nome,
                                    idadeEAno: filho.idadeEAno,
                                    escola: filho.escola,
                                    turno: filho.turno,
                                    horario: filho.horario,
                                    status: filho.status,
                                    onTap: () => _abrirModalDetalhes(context, uid, filho),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          side: const BorderSide(color: azulPrincipal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/meus-filhos'),
                        icon: const Icon(Icons.add, color: azulPrincipal),
                        label: const Text('Adicionar filho', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Card Método de Pagamento
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Método de pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton(onPressed: () {}, child: const Text('Editar', style: TextStyle(color: azulPrincipal))),
                        ],
                      ),
                      Text('Gerencie seu método de pagamento.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 16),
                      const CardCartao(ultimosDigitos: '1234', validade: '08/28', titular: 'Marcos Silva'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          side: const BorderSide(color: azulPrincipal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: azulPrincipal),
                        label: const Text('Adicionar cartão', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de configurações — itens de baixa prioridade sem
                // destaque de card, só divisórias, estilo iOS/Android Settings.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _linhaConfig(context, icone: Icons.notifications_outlined, texto: 'Notificações'),
                      _linhaConfig(context, icone: Icons.help_outline, texto: 'Ajuda e suporte'),
                      _linhaConfig(context, icone: Icons.info_outline, texto: 'Sobre o GoSchool'),
                      _linhaConfig(context, icone: Icons.settings_outlined, texto: 'Configurações'),
                      _linhaConfig(
                        context,
                        icone: Icons.logout,
                        texto: 'Sair',
                        cor: Colors.red,
                        ultimo: true,
                        onTap: () => _sair(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemInfo(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(texto, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  Widget _linhaConfig(
    BuildContext context, {
    required IconData icone,
    required String texto,
    Color? cor,
    bool ultimo = false,
    VoidCallback? onTap,
  }) {
    final Color corEfetiva = cor ?? Colors.grey[800]!;
    return InkWell(
      onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve!'))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(border: ultimo ? null : Border(bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(
          children: [
            Icon(icone, size: 20, color: cor ?? Colors.grey[600]),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(fontSize: 14, fontWeight: cor != null ? FontWeight.bold : FontWeight.w500, color: corEfetiva),
              ),
            ),
            if (cor == null) Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
