import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _chaveForm = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  void _cadastrarUsuario() {
    if (_chaveForm.currentState?.validate() ?? false) {
      setState(() => _carregando = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _carregando = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Faça login.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _chaveForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Comece agora',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie sua conta para gerenciar seus acessos',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  CampoTexto(
                    controlador: _nomeController,
                    rotulo: 'Nome completo',
                    icone: Icons.person_outline,
                    validador: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe seu nome';
                      }
                      return null;
                    },
                  ),

                  CampoTexto(
                    controlador: _emailController,
                    rotulo: 'E-mail',
                    icone: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Informe um e-mail válido';
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
                      if (valor == null || valor.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  CampoTexto(
                    controlador: _confirmaSenhaController,
                    rotulo: 'Confirmar Senha',
                    icone: Icons.lock_reset,
                    ocultar: true,
                    validador: (valor) {
                      if (valor != _senhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botão de Cadastrar
                  _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : botao('Cadastrar', _cadastrarUsuario),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}