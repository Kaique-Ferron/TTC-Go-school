import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../widgets/botoes.dart';
import '../widgets/campos.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Controladores dos campos
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Chave para validar os dados
  final _chaveForm = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLogin() {
    if (_chaveForm.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrando com: ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );

      // Aqui você fará a navegação para a próxima tela do projeto:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaPrincipal()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _chaveForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  const Icon(
                    Icons.lock_person_outlined,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),

                  // Título
                  const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Preencha seus dados para acessar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  CampoTexto(
                    controlador: _emailController,
                    rotulo: 'E-mail',
                    icone: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      return null;
                    },
                  ),
                  CampoTexto(
                    controlador: _senhaController,
                    rotulo: 'Senha',
                    icone: Icons.lock_outline,
                    ocultar: true,
                    validador: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe sua senha';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // 3. Botão Entrar (vindo de botoes.dart)
                  botao('Entrar', _fazerLogin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
=======

>>>>>>> cc1d891c33b12a82d82c5f36818855e7caff5cd7
