import 'package:flutter/material.dart';
import '../../widgets/card_perfil.dart';
import '../../widgets/box_seguranca.dart';
import '../../widgets/botoes.dart';
import '../../widgets/logo_goschool.dart';

class TelaSelecaoPerfil extends StatefulWidget {
  const TelaSelecaoPerfil({super.key});

  @override
  State<TelaSelecaoPerfil> createState() => _TelaSelecaoPerfilState();
}

class _TelaSelecaoPerfilState extends State<TelaSelecaoPerfil> {
  String? _perfilSelecionado;

  static const Color azulPrincipal = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _perfilSelecionado == null
                  ? _buildTelaEscolhaPerfil(context)
                  : _buildTelaPerfilSelecionado(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTelaEscolhaPerfil(BuildContext context) {
    return Column(
      key: const ValueKey('escolha_perfil'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoGoSchool(),
        const SizedBox(height: 20),
        const Text('Qual o seu perfil?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Selecione o perfil que melhor te representa para continuar o cadastro.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
        ),
        const SizedBox(height: 28),

        CardPerfil(
          titulo: 'Responsável',
          subtitulo: 'Sou responsável por um ou mais alunos e quero acompanhar as rotas.',
          corAccent: azulPrincipal,
          iconeBackground: const Color(0xFFE8F0FE),
          icone: Icons.family_restroom,
          onTap: () => setState(() => _perfilSelecionado = 'Responsável'),
        ),
        const SizedBox(height: 16),

        CardPerfil(
          titulo: 'Motorista',
          subtitulo: 'Sou motorista e quero gerenciar minhas rotas, paradas e acompanhar os alunos.',
          corAccent: laranjaMotorista,
          iconeBackground: const Color(0xFFFFF0E6),
          icone: Icons.directions_bus,
          onTap: () => setState(() => _perfilSelecionado = 'Motorista'),
        ),
        const SizedBox(height: 24),

        const BoxSeguranca(),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Já tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text('Fazer login', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelaPerfilSelecionado(BuildContext context) {
    final bool isResponsavel = _perfilSelecionado == 'Responsável';
    final Color corPerfil = isResponsavel ? azulPrincipal : laranjaMotorista;

    return Column(
      key: const ValueKey('perfil_selecionado'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _perfilSelecionado = null),
            icon: const Icon(Icons.arrow_back, size: 18, color: azulPrincipal),
            label: const Text('Voltar', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(color: azulPrincipal, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 20),

        const Text('Perfil selecionado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Agora é só preencher seus dados para criar sua conta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
        ),
        const SizedBox(height: 28),

        BotaoPrincipal(
          texto: 'Continuar como $_perfilSelecionado',
          cor: corPerfil,
          onPressed: () {
            // Passa o perfil selecionado para a tela de formulário de cadastro
            Navigator.pushNamed(
              context,
              '/cadastro',
              arguments: _perfilSelecionado,
            );
          },
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _perfilSelecionado = null),
          child: const Text('Escolher outro perfil', style: TextStyle(color: azulPrincipal, fontSize: 13, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}