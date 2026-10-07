import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/motorista_model.dart';
import '../../services/auth_service.dart';
import 'tela_financas_motorista.dart';

class TelaMotorista extends StatelessWidget {
  const TelaMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Utilizador não autenticado.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Dados do motorista não encontrados.')),
          );
        }

        final dadosMap = snapshot.data!.data() ?? {};
        final Motorista motorista = Motorista.fromMap(dadosMap);

        final email = dadosMap['email'] as String? ?? 'motorista.teste@gmail.com';
        final telefone = dadosMap['telefone'] as String? ?? '(11) 99999-8888';
        final localizacao = dadosMap['localizacao'] as String? ?? 'São Paulo, SP';
        final membroDesde = dadosMap['membroDesde'] as String? ?? 'Jan/2024';
        final passageiros = dadosMap['passageiros'] as String? ?? '15';
        final rotasAtivas = dadosMap['rotasAtivas'] as String? ?? '2';
        final avaliacao = dadosMap['avaliacao'] as String? ?? '4,9/5';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Row(
            children: [
              // 1. MENU LATERAL
              Container(
                width: 240,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          // LOGÓTIPO ADICIONADO AQUI
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/logo.png', // fundo transparente
                              width: 130,          // Podes ajustar a largura conforme preferires
                              height: 40,          // Podes ajustar a altura conforme preferires
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 16),

                    _buildMenuItem(Icons.home_outlined, 'Painel Principal', false, () {}),
                    _buildMenuItem(Icons.alt_route, 'Minhas Rotas', false, () {}),
                    _buildMenuItem(Icons.person, 'Meu Perfil', true, () {}),
                    _buildMenuItem(
                      Icons.payments_outlined,
                      'Finanças',
                      false,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaFinancasMotorista()),
                      ),
                    ),
                    _buildMenuItem(Icons.chat_bubble_outline, 'Mensagens', false, () {}),
                    _buildMenuItem(Icons.notifications_none, 'Notificações', false, () {}, badge: '3'),
                    _buildMenuItem(Icons.settings_outlined, 'Configurações', false, () {}),

                    const Spacer(),
                    const Divider(height: 1, color: Colors.black12),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton.icon(
                        onPressed: () async {
                          await AuthService.instance.sair();
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Sair', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),

              // 2. CONTEÚDO PRINCIPAL
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Meu Perfil', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              SizedBox(height: 4),
                              Text('Gerencie suas informações e preferências.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_none, color: Colors.black54),
                                    onPressed: () {},
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFE8EEFC),
                                backgroundImage: motorista.fotoPerfil.isNotEmpty ? NetworkImage(motorista.fotoPerfil) : null,
                                child: motorista.fotoPerfil.isEmpty
                                    ? Text(motorista.nome.isNotEmpty ? motorista.nome[0] : 'C', style: const TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Olá, ${motorista.nome.split(' ')[0]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                                  const Text('Motorista', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 32),

                      // LINHA SUPERIOR
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 42,
                                            backgroundColor: const Color(0xFFE8EEFC),
                                            backgroundImage: motorista.fotoPerfil.isNotEmpty ? NetworkImage(motorista.fotoPerfil) : null,
                                            child: motorista.fotoPerfil.isEmpty
                                                ? Text(motorista.nome.isNotEmpty ? motorista.nome[0] : 'C', style: const TextStyle(fontSize: 28, color: Color(0xFF1D58E2), fontWeight: FontWeight.bold))
                                                : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: InkWell(
                                              onTap: () => _selecionarEAtualizarFoto(context, uid),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(color: Color(0xFF1D58E2), shape: BoxShape.circle),
                                                child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(motorista.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E293B))),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1D58E2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text('Motorista', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildInfoRow(Icons.mail_outline, email),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(Icons.phone_outlined, telefone),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(Icons.location_on_outlined, localizacao),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(Icons.calendar_today_outlined, 'Membro desde $membroDesde'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Meu Veículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                      TextButton.icon(
                                        onPressed: () => _mostrarDialogoEditarVeiculo(context, uid, motorista.veiculo, motorista.placa),
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1D58E2)),
                                        label: const Text('Editar', style: TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Center(
                                    child: Icon(Icons.directions_bus, size: 70, color: Color(0xFF1D58E2)),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildVehicleInfo(Icons.directions_bus_outlined, motorista.veiculo),
                                  const Divider(height: 24),
                                  _buildVehicleInfo(Icons.credit_card_outlined, motorista.placa),
                                  const Divider(height: 24),
                                  _buildVehicleInfo(Icons.group_outlined, '$passageiros passageiros'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // LINHA INFERIOR
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.calendar_month_outlined, color: Color(0xFF1E293B)),
                                      SizedBox(width: 8),
                                      Text('Minha agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Material(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      leading: const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 28),
                                      title: const Text('Manhã', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('07:00 - 12:00'),
                                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Material(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      leading: const Icon(Icons.nights_stay_outlined, color: Colors.blue, size: 28),
                                      title: const Text('Tarde', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: const Text('13:00 - 18:00'),
                                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: const BorderSide(color: Color(0xFF1D58E2)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {},
                                      icon: const Icon(Icons.alt_route, color: Color(0xFF1D58E2)),
                                      label: const Text('Ver minhas rotas', style: TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.bar_chart, color: Color(0xFF1D58E2)),
                                      SizedBox(width: 8),
                                      Text('Resumo da atividade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.5,
                                    children: [
                                      _buildResumoItem(Icons.alt_route, 'Rotas ativas', rotasAtivas, const Color(0xFF1D58E2)),
                                      _buildResumoItem(Icons.group_outlined, 'Alunos transportados', passageiros, Colors.blueGrey),
                                      _buildResumoItem(Icons.directions_bus_outlined, 'Viagens concluídas', motorista.corridas, Colors.green),
                                      _buildResumoItem(Icons.star_outline, 'Avaliação', avaliacao, Colors.amber),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selecionarEAtualizarFoto(BuildContext context, String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagemSelecionada = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagemSelecionada != null) {
      final caminhoOuUrl = imagemSelecionada.path;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({'fotoPerfil': caminhoOuUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
      );
    }
  }

  void _mostrarDialogoEditarVeiculo(BuildContext context, String uid, String veiculoAtual, String placaAtual) {
    final TextEditingController veiculoController = TextEditingController(text: veiculoAtual);
    final TextEditingController placaController = TextEditingController(text: placaAtual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Veículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: veiculoController,
                decoration: const InputDecoration(
                  labelText: 'Modelo do Veículo (ex: Van Mercedes)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa (ex: ABC1D23)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D58E2)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .update({
                  'veiculo': veiculoController.text.trim(),
                  'placa': placaController.text.trim(),
                });
                Navigator.of(context).pop();
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isSelected, VoidCallback onTap, {String? badge}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1D58E2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildVehicleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1D58E2)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildResumoItem(IconData icon, String titulo, String valor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
