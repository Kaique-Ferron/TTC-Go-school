import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';

class TelaCadastro extends StatelessWidget {
  const TelaCadastro({super.key});

  static const Color azulResponsavel = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  @override
  Widget build(BuildContext context) {
    // Recebe o perfil escolhido ('Responsável' ou 'Motorista')
    final String perfil = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Responsável';
    final bool isResponsavel = perfil == 'Responsável';
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
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: 18, color: corPerfil),
                    label: Text('Voltar', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),

                // Chip na cor do perfil selecionado
                Chip(
                  avatar: Icon(
                    isResponsavel ? Icons.person : Icons.directions_bus,
                    size: 16,
                    color: corPerfil,
                  ),
                  label: Text(perfil, style: TextStyle(color: corPerfil, fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: corPerfil.withOpacity(0.1),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 8),

                Text('Cadastro de $perfil', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Preencha seus dados para criar sua conta.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 28),
                ),
                const SizedBox(height: 6),
                Text('Adicionar foto\n(opcional)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                const SizedBox(height: 20),

                const CampoTextoCustomizado(hintText: 'Nome completo', prefixIcon: Icons.person_outline),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'CPF', prefixIcon: Icons.badge_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'Telefone / WhatsApp', prefixIcon: Icons.phone_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'E-mail', prefixIcon: Icons.email_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'Endereço completo', prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'Senha', prefixIcon: Icons.lock_outline, obscureText: true),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'Confirmar senha', prefixIcon: Icons.lock_outline, obscureText: true),
                const SizedBox(height: 20),

                // Botão de submissão na cor do perfil
                BotaoPrincipal(
                  texto: 'Criar minha conta',
                  icone: Icons.person_add_alt_1,
                  cor: corPerfil,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: Text('Fazer login', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13)),
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