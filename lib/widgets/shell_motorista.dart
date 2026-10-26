import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/cores.dart';
import '../telas/chat/tela_conversas.dart';
import '../telas/motorista/tela_financas_motorista.dart';
import '../telas/motorista/tela_chamada.dart';
import '../telas/motorista/tela_rota.dart';
import 'logo_goschool.dart';

/// Shell responsivo compartilhado pelas telas do Motorista (Painel, Finanças, ...).
/// Em telas largas (Web com janela maximizada) mostra o menu lateral fixo;
/// abaixo do breakpoint ele vira um Drawer com AppBar, pra não quebrar o
/// layout quando o app roda em janelas estreitas ou no celular.
class ShellMotorista extends StatelessWidget {
  final String itemSelecionado;
  final WidgetBuilder builder;

  const ShellMotorista({super.key, required this.itemSelecionado, required this.builder});

  static const double _breakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _breakpoint;

        if (isWide) {
          return Scaffold(
            backgroundColor: AppCores.fundo(context),
            body: Row(
              children: [
                SizedBox(
                  width: 240,
                  child: _MenuMotorista(itemSelecionado: itemSelecionado),
                ),
                VerticalDivider(thickness: 1, width: 1, color: AppCores.borda(context)),
                Expanded(child: Builder(builder: builder)),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppCores.fundo(context),
          appBar: AppBar(
            title: Text(itemSelecionado),
          ),
          drawer: Drawer(
            width: 260,
            child: SafeArea(
              child: _MenuMotorista(itemSelecionado: itemSelecionado, isDrawer: true),
            ),
          ),
          body: Builder(builder: builder),
        );
      },
    );
  }
}

class _MenuMotorista extends StatelessWidget {
  final String itemSelecionado;
  final bool isDrawer;

  const _MenuMotorista({required this.itemSelecionado, this.isDrawer = false});

  void _irPara(BuildContext context, String destino) {
    if (isDrawer) Navigator.pop(context);
    if (destino == itemSelecionado) return;

    if (destino == 'Finanças') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaFinancasMotorista()));
    } else if (destino == 'Mensagens') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaConversas()));
    } else if (destino == 'Chamada') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaChamada()));
    } else if (destino == 'Minhas Rotas') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaRota()));
    } else if (destino == 'Meu Perfil') {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const LogoGoSchool(fontSize: 22),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppCores.laranjaMotorista,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.directions_bus, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppCores.borda(context)),

        // Expanded + SingleChildScrollView (em vez de um Spacer no fim da
        // Column) pra rolar os itens em vez de estourar em janelas baixas.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildMenuItem(context, Icons.home_outlined, 'Painel Principal'),
                _buildMenuItem(context, Icons.alt_route, 'Minhas Rotas'),
                _buildMenuItem(context, Icons.how_to_reg_outlined, 'Chamada'),
                _buildMenuItem(context, Icons.person, 'Meu Perfil'),
                _buildMenuItem(context, Icons.payments_outlined, 'Finanças'),
                _buildMenuItem(context, Icons.chat_bubble_outline, 'Mensagens'),
                _buildMenuItem(context, Icons.notifications_none, 'Notificações', badge: '3'),
                _buildMenuItem(context, Icons.settings_outlined, 'Configurações'),
              ],
            ),
          ),
        ),

        Divider(height: 1, color: AppCores.borda(context)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton.icon(
            onPressed: () async {
              await AuthService.instance.sair();
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {String? badge}) {
    final bool isSelected = title == itemSelecionado;
    // tileColor (em vez de pintar a cor num Container externo) deixa o
    // próprio ListTile cuidar do Material/ink splash corretamente.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        tileColor: isSelected ? AppCores.azulPrincipal : Colors.transparent,
        leading: Icon(icon, color: isSelected ? Colors.white : AppCores.textoSecundario(context)),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppCores.textoPrincipal(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () => _irPara(context, title),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
