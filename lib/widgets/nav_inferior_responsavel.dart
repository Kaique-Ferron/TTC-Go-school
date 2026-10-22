import 'package:flutter/material.dart';
import '../theme/cores.dart';

/// Barra de navegação inferior para as telas principais do Responsável
/// (Meus Filhos, Início, Mensagens, Perfil) — navegação primária, no padrão
/// de apps de transporte (Uber, 99), em vez de deixar tudo escondido no
/// Drawer. Mensagens fica aqui (1 toque) em vez de só dentro do menu ☰.
class NavInferiorResponsavel extends StatelessWidget {
  final String abaSelecionada; // 'Meus Filhos', 'Início', 'Mensagens' ou 'Perfil'

  const NavInferiorResponsavel({super.key, required this.abaSelecionada});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _indiceDaAba(abaSelecionada),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppCores.azulPrincipal,
      unselectedItemColor: AppCores.textoSecundario(context),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
      unselectedLabelStyle: const TextStyle(fontSize: 11.5),
      onTap: (index) => _navegar(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people_rounded), label: 'Meus Filhos'),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Mensagens'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
      ],
    );
  }

  int _indiceDaAba(String aba) {
    switch (aba) {
      case 'Meus Filhos':
        return 0;
      case 'Início':
        return 1;
      case 'Mensagens':
        return 2;
      case 'Perfil':
      default:
        return 3;
    }
  }

  void _navegar(BuildContext context, int index) {
    if (index == _indiceDaAba(abaSelecionada)) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/meus-filhos');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/inicio');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/meu-perfil');
        break;
    }
  }
}
