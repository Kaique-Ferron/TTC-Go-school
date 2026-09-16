import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/botoes.dart';
import '../../widgets/campos.dart';
import '../../widgets/box_seguranca.dart';
import '../../widgets/logo_goschool.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _perfil = 'Responsável';
  bool _carregando = false;

  static const Color azulResponsavel = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await AuthService.instance.recuperarSenha(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link de recuperação enviado! Verifique seu e-mail.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.instance.descreverErro(e)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isResponsavel = _perfil == 'Responsável';
    final Color corPerfil = isResponsavel ? azulResponsavel : laranjaMotorista;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const LogoGoSchool(),
                  const SizedBox(height: 20),

                  const Text('Recuperar senha', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Informe seu e-mail cadastrado para receber o link de recuperação.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                  ),
                  const SizedBox(height: 24),

                  // Seletor de Perfil
                  SeletorPerfilTab(
                    perfilSelecionado: _perfil,
                    onChanged: (novoPerfil) => setState(() => _perfil = novoPerfil),
                  ),
                  const SizedBox(height: 20),

                  CampoTextoCustomizado(
                    controller: _emailController,
                    hintText: 'E-mail cadastrado',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail';
                      if (!valor.contains('@') || !valor.contains('.')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Botão dinâmico na cor do perfil
                  BotaoPrincipal(
                    texto: 'Enviar link de recuperação',
                    icone: Icons.send_outlined,
                    cor: corPerfil,
                    carregando: _carregando,
                    onPressed: _enviarLink,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lembrou sua senha? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Fazer login', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const BoxSeguranca(
                    titulo: 'Seus dados estão protegidos',
                    subtitulo: 'Utilizamos segurança e criptografia avançada para proteger suas informações.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
