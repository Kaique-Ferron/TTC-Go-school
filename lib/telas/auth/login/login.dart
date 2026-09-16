import 'package:flutter/material.dart';
// import '../../../services/auth_service.dart'; // Auth temporariamente desativado para testes de navegação
import '../../../theme/cores.dart';
import '../../../widgets/botoes.dart';
import '../../../widgets/campos.dart';
import '../../../widgets/logo_goschool.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  String _perfil = 'Responsável';
  bool _lembrarDeMim = false;
  bool _mostrarSenha = false;
  // bool _carregando = false; // usado apenas pela chamada real de login (desativada)

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // ===== Login real com Firebase Auth (temporariamente desativado para testes) =====
  // Future<void> _entrar() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _carregando = true);
  //   try {
  //     await AuthService.instance.entrar(
  //       email: _emailController.text.trim(),
  //       senha: _senhaController.text,
  //     );
  //     // Login bem-sucedido: o AuthGate detecta a mudança de estado
  //     // de autenticação e troca a tela automaticamente.
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AuthService.descreverErro(e)),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _carregando = false);
  //   }
  // }

  // Login "fake" apenas para navegação durante os testes de tela
  // (sem checar credenciais nem chamar o Firebase).
  void _entrar() {
    Navigator.pushReplacementNamed(context, '/landpage');
  }

  @override
  Widget build(BuildContext context) {
    final Color corPerfil = AppCores.porPerfil(_perfil);

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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LogoGoSchool(),
                  const SizedBox(height: 16),
                  const Text('Bem-vindo de volta!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Faça login para acessar sua conta', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 24),

                  // Seletor de Perfil
                  SeletorPerfilTab(
                    perfilSelecionado: _perfil,
                    onChanged: (novoPerfil) => setState(() => _perfil = novoPerfil),
                  ),
                  const SizedBox(height: 20),

                  CampoTextoCustomizado(
                    controller: _emailController,
                    hintText: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail';
                      if (!valor.contains('@') || !valor.contains('.')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CampoTextoCustomizado(
                    controller: _senhaController,
                    hintText: 'Senha',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_mostrarSenha,
                    validator: (valor) =>
                        (valor == null || valor.isEmpty) ? 'Informe sua senha' : null,
                    suffixIcon: IconButton(
                      icon: Icon(_mostrarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                      onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _lembrarDeMim,
                            onChanged: (val) => setState(() => _lembrarDeMim = val ?? false),
                            activeColor: corPerfil,
                          ),
                          Text('Lembrar de mim', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/recuperar-senha');
                        },
                        child: Text(
                          'Esqueceu sua senha?',
                          style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botão Entrar adaptativo à cor do perfil selecionado
                  BotaoPrincipal(
                    texto: 'Entrar',
                    icone: Icons.login,
                    cor: corPerfil,
                    onPressed: _entrar,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ainda não tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/selecao-perfil');
                        },
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
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
