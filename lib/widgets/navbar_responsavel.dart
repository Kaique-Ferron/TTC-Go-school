import 'package:flutter/material.dart';
import 'logo_goschool.dart';

class NavbarResponsavel extends StatelessWidget {
  final String itemSelecionado; // Ex: 'Meu Perfil', 'Painel Principal', etc.

  const NavbarResponsavel({
    super.key,
    this.itemSelecionado = 'Meu Perfil',
  });

  static const Color azulPrincipal = Color(0xFF1D58E2);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo GoSchool com ícone da van
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const LogoGoSchool(fontSize: 22),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: azulPrincipal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista de Opções do Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildItemMenu(
                    context,
                    titulo: 'Painel Principal',
                    icone: Icons.home_outlined,
                    rota: '/painel-principal',
                  ),
                  _buildItemMenu(
                    context,
                    titulo: 'Procurar Motorista',
                    icone: Icons.search_outlined,
                    rota: '/procurar-motorista',
                  ),
                  _buildItemMenu(
                    context,
                    titulo: 'Meu Perfil',
                    icone: Icons.person_outline,
                    rota: '/meu-perfil',
                  ),
                  _buildItemMenu(
                    context,
                    titulo: 'Meus filhos',
                    icone: Icons.people_outline,
                    rota: '/meus-filhos',
                  ),
                  _buildItemMenu(
                    context,
                    titulo: 'Mensagens (chat)',
                    icone: Icons.chat_bubble_outline,
                    rota: '/chat',
                  ),
                  _buildItemMenu(
                    context,
                    titulo: 'Configurações',
                    icone: Icons.settings_outlined,
                    rota: '/configuracoes',
                  ),
                  const SizedBox(height: 10),
                  _buildItemMenu(
                    context,
                    titulo: 'Sair',
                    icone: Icons.logout,
                    rota: '/',
                    isSair: true,
                  ),
                ],
              ),
            ),

            // Ilustração do Ônibus no Rodapé
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: azulPrincipal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemMenu(
    BuildContext context, {
    required String titulo,
    required IconData icone,
    required String rota,
    bool isSair = false,
  }) {
    final bool isSelected = itemSelecionado == titulo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected
            ? azulPrincipal
            : (titulo == 'Configurações' ? const Color(0xFFF1F5F9) : Colors.transparent),
        leading: Icon(
          icone,
          color: isSelected ? Colors.white : (isSair ? Colors.grey[700] : Colors.grey[700]),
          size: 22,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: isSelected ? Colors.white : (isSair ? Colors.grey[800] : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14.5,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Fecha o Drawer
          if (isSair) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else {
            // Navega para a rota correspondente se necessário
          }
        },
      ),
    );
  }
}