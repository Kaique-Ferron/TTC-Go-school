import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class CadastroMotorista extends StatefulWidget {
  const CadastroMotorista({super.key});

  @override
  State<CadastroMotorista> createState() => _CadastroMotoristaState();
}

class _CadastroMotoristaState extends State<CadastroMotorista> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final telefoneController = TextEditingController();
  final cpfController = TextEditingController();
  final cnhController = TextEditingController();
  final licencaController = TextEditingController();
  final placaController = TextEditingController();
  final veiculoController = TextEditingController();

  bool cadastrando = false;

  Future<void> cadastrarMotorista() async {
    if (nomeController.text.isEmpty ||
        emailController.text.isEmpty ||
        senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome, e-mail e senha.'),
        ),
      );

      return;
    }

    setState(() {
      cadastrando = true;
    });

    try {
      // 1. Cria a conta no Firebase Authentication
      final uid = await AuthService.instance.cadastrar(
        email: emailController.text.trim(),
        senha: senhaController.text.trim(),
      );

      // 2. Cria o objeto motorista
      final motorista = Usuario(
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        telefone: telefoneController.text.trim(),
        cpf: cpfController.text.trim(),

        // IMPORTANTE:
        // Isso fará o Usuario virar "motorista"
        perfil: 'Motorista',

        cnh: cnhController.text.trim(),
        licenca: licencaController.text.trim(),
        placa: placaController.text.trim(),
        veiculo: veiculoController.text.trim(),
      );

      // 3. Salva os dados no Firestore
      await FirestoreService.instance.salvarUsuario(
        uid,
        motorista,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motorista cadastrado com sucesso!'),
        ),
      );

      // Volta para a tela anterior
      Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.descreverErro(erro),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cadastrando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    telefoneController.dispose();
    cpfController.dispose();
    cnhController.dispose();
    licencaController.dispose();
    placaController.dispose();
    veiculoController.dispose(); // <- ADICIONADO AQUI

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Motorista'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: cpfController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: cnhController,
              decoration: const InputDecoration(
                labelText: 'CNH',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: licencaController,
              decoration: const InputDecoration(
                labelText: 'Licença',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // CAMPO DO VEÍCULO ADICIONADO
            TextField(
              controller: veiculoController,
              decoration: const InputDecoration(
                labelText: 'Veículo (ex: Van Renault Master)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: placaController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa do veículo',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: cadastrando
                    ? null
                    : cadastrarMotorista,

                child: cadastrando
                    ? const CircularProgressIndicator()
                    : const Text(
                        'CADASTRAR MOTORISTA',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}