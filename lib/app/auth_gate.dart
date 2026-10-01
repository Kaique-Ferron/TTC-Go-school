import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import '../services/sessao_provider.dart';
import '../services/firestore_service.dart';

import '../telas/auth/login/login.dart';
import '../telas/landpage/landpage-tela.dart';
import '../telas/motorista/tela_motorista.dart';

/// Decide a tela inicial com base no estado de autenticação (via
/// [SessaoProvider]) e no tipo de perfil do usuário: Responsável cai na
/// aba "Início" (landpage); Motorista cai no painel dele. Reage
/// automaticamente a login/logout em qualquer parte do app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    if (!logado) {
      return const TelaLogin();
    }

    final uid = context.watch<SessaoProvider>().uid!;

    return StreamBuilder<Usuario?>(
      stream: FirestoreService.instance.usuarioStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final usuario = snapshot.data;
        if (usuario == null) {
          return const Scaffold(body: Center(child: Text('Dados do usuário não encontrados.')));
        }

        return usuario.tipoPerfil == 'motorista' ? const TelaMotorista() : const LandpageTela();
      },
    );
  }
}
