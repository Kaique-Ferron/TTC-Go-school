import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/motorista_model.dart';
import '../../services/auth_service.dart';
import '../../theme/cores.dart';
import '../../widgets/foto_perfil_provider.dart';
import '../../widgets/shell_motorista.dart';

/// "Meu Perfil" do Motorista — dados pessoais e veículo. Separada do
/// Painel Principal (TelaMotorista): no Uber/99 Driver essas são telas
/// diferentes, uma é o painel do dia a dia e a outra é a ficha do
/// motorista; antes aqui as duas eram a mesma tela com dois nomes.
class TelaPerfilMotorista extends StatelessWidget {
  const TelaPerfilMotorista({super.key});

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

        final email =
            dadosMap['email'] as String? ?? 'motorista.teste@gmail.com';
        final telefone = dadosMap['telefone'] as String? ?? '(11) 99999-8888';
        final localizacao =
            dadosMap['localizacao'] as String? ?? 'São Paulo, SP';
        final membroDesde = dadosMap['membroDesde'] as String? ?? 'Jan/2024';
        final passageiros = dadosMap['passageiros'] as String? ?? '15';

        return ShellMotorista(
          itemSelecionado: 'Meu Perfil',
          builder: (context) => _buildConteudo(
            context,
            uid: uid,
            motorista: motorista,
            email: email,
            telefone: telefone,
            localizacao: localizacao,
            membroDesde: membroDesde,
            passageiros: passageiros,
          ),
        );
      },
    );
  }

  Widget _buildConteudo(
    BuildContext context, {
    required String uid,
    required Motorista motorista,
    required String email,
    required String telefone,
    required String localizacao,
    required String membroDesde,
    required String passageiros,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 850;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meu Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gerencie suas informações e preferências.',
                style: TextStyle(
                  color: AppCores.textoSecundario(context),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: isWide ? 32 : 24),

              Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildCardDadosPessoais(
                      context,
                      uid,
                      motorista,
                      email,
                      telefone,
                      localizacao,
                      membroDesde,
                    ),
                  ),
                  SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 20),
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildCardVeiculo(
                      context,
                      uid,
                      motorista,
                      passageiros,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardDadosPessoais(
    BuildContext context,
    String uid,
    Motorista motorista,
    String email,
    String telefone,
    String localizacao,
    String membroDesde,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
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
                    backgroundImage: fotoPerfilProvider(motorista.fotoPerfil),
                    child: motorista.fotoPerfil.isEmpty
                        ? Text(
                            motorista.nome.isNotEmpty ? motorista.nome[0] : 'C',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(0xFF1D58E2),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _selecionarEAtualizarFoto(context, uid),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D58E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motorista.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppCores.textoPrincipal(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D58E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Motorista',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(context, Icons.mail_outline, email),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.phone_outlined, telefone),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.location_on_outlined, localizacao),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            'Membro desde $membroDesde',
          ),
        ],
      ),
    );
  }

  Widget _buildCardVeiculo(
    BuildContext context,
    String uid,
    Motorista motorista,
    String passageiros,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                'Meu Veículo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
              TextButton.icon(
                onPressed: () => _mostrarDialogoEditarVeiculo(
                  context,
                  uid,
                  motorista.veiculo,
                  motorista.placa,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Color(0xFF1D58E2),
                ),
                label: const Text(
                  'Editar',
                  style: TextStyle(
                    color: Color(0xFF1D58E2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Icon(
              Icons.directions_bus,
              size: 70,
              color: Color(0xFF1D58E2),
            ),
          ),
          const SizedBox(height: 16),
          _buildVehicleInfo(
            context,
            Icons.directions_bus_outlined,
            motorista.veiculo,
          ),
          const Divider(height: 24),
          _buildVehicleInfo(
            context,
            Icons.credit_card_outlined,
            motorista.placa,
          ),
          const Divider(height: 24),
          _buildVehicleInfo(
            context,
            Icons.group_outlined,
            '$passageiros passageiros',
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarEAtualizarFoto(
    BuildContext context,
    String uid,
  ) async {
    final ImagePicker picker = ImagePicker();
    // maxWidth/maxHeight/imageQuality baixos de propósito: a foto vai
    // direto dentro do documento do Firestore (sem Firebase Storage, que
    // exige o plano pago Blaze), então precisa ficar bem pequena pra caber
    // no limite de 1MB por documento.
    final XFile? imagemSelecionada = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 240,
      maxHeight: 240,
      imageQuality: 60,
    );
    if (imagemSelecionada == null) return;

    try {
      final bytes = await imagemSelecionada.readAsBytes();
      if (bytes.length > 700 * 1024) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Essa foto é grande demais, tenta uma menor.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'fotoPerfil': dataUri,
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível enviar a foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoEditarVeiculo(
    BuildContext context,
    String uid,
    String veiculoAtual,
    String placaAtual,
  ) {
    final TextEditingController veiculoController = TextEditingController(
      text: veiculoAtual,
    );
    final TextEditingController placaController = TextEditingController(
      text: placaAtual,
    );

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D58E2),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .update({
                      'veiculo': veiculoController.text.trim(),
                      'placa': placaController.text.trim(),
                    });
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppCores.textoSecundario(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppCores.textoPrincipal(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1D58E2)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppCores.textoPrincipal(context),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
