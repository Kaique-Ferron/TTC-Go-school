import 'package:flutter/material.dart';
import '../../models/filho.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/card_filho.dart';
import '../../widgets/card_cartao.dart';
import '../../widgets/modal_info_filho.dart';

class TelaMeuPerfil extends StatelessWidget {
  const TelaMeuPerfil({super.key});

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
    // Guarda de sessão real (temporariamente desativada — login/cadastro
    // estão em modo de teste e não autenticam de verdade no Firebase):
    // final uid = AuthService.instance.uidAtual;
    // if (uid == null) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFF8FAFC),
    //     body: Center(
    //       child: TextButton(
    //         onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
    //         child: const Text('Sessão expirada. Toque para fazer login novamente.'),
    //       ),
    //     ),
    //   );
    // }
    final uid = AuthService.instance.uidAtual ?? 'usuario-teste';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Meu Perfil'),
      body: StreamBuilder<Usuario?>(
        stream: FirestoreService.instance.usuarioStream(uid),
        builder: (context, snapshotUsuario) {
          if (snapshotUsuario.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuario = snapshotUsuario.data;

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
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            usuario != null && usuario.nome.isNotEmpty ? usuario.nome : 'Sem nome cadastrado',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              usuario?.perfil ?? 'Responsável',
                              style: const TextStyle(color: azulPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildItemInfo(Icons.email_outlined, usuario?.email ?? AuthService.instance.emailAtual ?? '—'),
                      const SizedBox(height: 8),
                      _buildItemInfo(
                        Icons.phone_outlined,
                        usuario != null && usuario.telefone.isNotEmpty ? usuario.telefone : 'Não informado',
                      ),
                      const SizedBox(height: 8),
                      _buildItemInfo(
                        Icons.location_on_outlined,
                        usuario != null && usuario.bairro.isNotEmpty ? usuario.bairro : 'Endereço não informado',
                      ),
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
                            onPressed: () {
                              Navigator.pushNamed(context, '/meus-filhos');
                            },
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
                              child: Text(
                                'Nenhum filho cadastrado ainda.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/meus-filhos');
                        },
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
                          TextButton(
                            onPressed: () {},
                            child: const Text('Editar', style: TextStyle(color: azulPrincipal)),
                          ),
                        ],
                      ),
                      Text('Gerencie seu método de pagamento.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 16),
                      const CardCartao(
                        ultimosDigitos: '1234',
                        validade: '08/28',
                        titular: 'Marcos Silva',
                      ),
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
}
