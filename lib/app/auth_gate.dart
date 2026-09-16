import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../telas/auth/login/login.dart';
import '../telas/meu_perfil/meu_perfil.dart';

/// Decide a tela inicial com base no estado de autenticação e reage
/// automaticamente a login/logout em qualquer parte do app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AuthService.instance.logado,
      initialData: AuthService.instance.uidAtual != null,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return const TelaMeuPerfil();
        }
        return const TelaLogin();
      },
    );
  }
}
