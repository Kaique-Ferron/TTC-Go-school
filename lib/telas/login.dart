import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';
import '../widgets/logo_goschool.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  String _perfil = 'Responsável';
  bool _lembrarDeMim = false;
  bool _mostrarSenha = false;

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const LogoGoSchool(),
                const SizedBox(height: 16),
                const Text('Bem-vindo de volta!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Faça login para acessar sua conta', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 24),

                SeletorPerfilTab(
                  perfilSelecionado: _perfil,
                  onChanged: (novoPerfil) => setState(() => _perfil = novoPerfil),
                ),
                const SizedBox(height: 20),

                const CampoTextoCustomizado(
                  hintText: 'E-mail ou telefone',
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 12),
                CampoTextoCustomizado(
                  hintText: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_mostrarSenha,
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
                          activeColor: const Color(0xFF1D58E2),
                        ),
                        Text('Lembrar de mim', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navega para a tela de recuperar senha
                        Navigator.pushNamed(context, '/recuperar-senha');
                      },
                      child: const Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                BotaoPrincipal(
                  texto: 'Entrar',
                  icone: Icons.login,
                  onPressed: () {},
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ainda não tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        // Navega para a seleção de perfil de cadastro
                        Navigator.pushNamed(context, '/selecao-perfil');
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}