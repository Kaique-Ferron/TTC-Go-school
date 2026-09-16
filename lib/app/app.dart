import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_provider.dart';
import '../telas/selecao_perfil/selecao_perfil.dart';
import '../telas/auth/cadastro/cadastro.dart';
import '../telas/recuperar_senha/recuperar_senha.dart';
import '../telas/landpage/landpage-tela.dart';
import '../telas/meu_perfil/meu_perfil.dart';
import '../telas/meus_filhos/meus_filhos.dart';
import 'auth_gate.dart';


class GoSchoolApp extends StatelessWidget {
  const GoSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessaoProvider(),
      child: MaterialApp(
        title: 'GoSchool',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthGate(),
        routes: {
          '/selecao-perfil': (context) => const TelaSelecaoPerfil(),
          '/cadastro': (context) => const TelaCadastro(),
          '/recuperar-senha': (context) => const TelaRecuperarSenha(),
          '/landpage': (context) => const LandpageTela(),
          '/meu-perfil': (context) => const TelaMeuPerfil(),
          '/meus-filhos': (context) => const TelaMeusFilhos(),
        },
      ),
    );
  }
}