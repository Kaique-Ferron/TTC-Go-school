import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';
import '../widgets/box_seguranca.dart';
import '../widgets/logo_goschool.dart';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  String _perfil = 'Responsável';

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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const LogoGoSchool(),
                const SizedBox(height: 20),

                const Text('Recuperar senha', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Informe seu e-mail ou telefone cadastrado para receber o link de recuperação.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                ),
                const SizedBox(height: 24),

                SeletorPerfilTab(
                  perfilSelecionado: _perfil,
                  onChanged: (novoPerfil) => setState(() => _perfil = novoPerfil),
                ),
                const SizedBox(height: 20),

                const CampoTextoCustomizado(hintText: 'E-mail ou telefone', prefixIcon: Icons.email_outlined),
                const SizedBox(height: 20),

                BotaoPrincipal(
                  texto: 'Enviar link de recuperação',
                  icone: Icons.send_outlined,
                  onPressed: () {},
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lembrou sua senha? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Fazer login', style: TextStyle(color: Color(0xFF1D58E2), fontWeight: FontWeight.bold, fontSize: 13)),
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
    );
  }
}