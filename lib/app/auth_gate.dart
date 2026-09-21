import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_provider.dart';
import '../telas/auth/login/login.dart';
import '../telas/landpage/landpage-tela.dart';

/// Decide a tela inicial com base no estado de autenticação (via
/// [SessaoProvider]) e reage automaticamente a login/logout em qualquer
/// parte do app. Ao logar, o Responsável cai na aba "Início" (landpage),
/// que é a home real do app — Meu Perfil e Meus Filhos ficam a uma aba
/// de distância na barra inferior.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    return logado ? const LandpageTela() : const TelaLogin();
  }
}
