import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_provider.dart';
import '../telas/auth/login/login.dart';
import '../telas/meu_perfil/meu_perfil.dart';

/// Decide a tela inicial com base no estado de autenticação (via
/// [SessaoProvider]) e reage automaticamente a login/logout em qualquer
/// parte do app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    return logado ? const TelaMeuPerfil() : const TelaLogin();
  }
}
