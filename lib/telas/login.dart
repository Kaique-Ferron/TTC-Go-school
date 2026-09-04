import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';

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
                // Logo GoSchool
                const Text(
                  'GO SCHOOL',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1D58E2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Faça login para acessar sua conta',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Seletor Responsável / Motorista
                SeletorPerfilTab(
                  perfilSelecionado: _perfil,
                  onChanged: (novoPerfil) {
                    setState(() => _perfil = novoPerfil);
                  },
                ),
                const SizedBox(height: 20),

                // Campos de Entrada
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
                    icon: Icon(
                      _mostrarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _mostrarSenha = !_mostrarSenha);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Lembrar de mim & Esqueseu senha
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
                        // Navegar para recuperação de senha
                      },
                      child: const Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          color: Color(0xFF1D58E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botão Entrar
                BotaoPrincipal(
                  texto: 'Entrar',
                  icone: Icons.login,
                  onPressed: () {},
                ),
                const SizedBox(height: 24),

                // Divisor Social
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('ou continue com', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 16),

                // Botões de Autenticação Social
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                        label: const Text('Google', style: TextStyle(color: Colors.black87)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.window, size: 18, color: Colors.blue),
                        label: const Text('Microsoft', style: TextStyle(color: Colors.black87)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Link para Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ainda não tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/cadastro');
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: Color(0xFF1D58E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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