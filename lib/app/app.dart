import 'package:flutter/material.dart';
import '../telas/login.dart';
import '../telas/selecao_perfil.dart';
import '../telas/cadastro.dart';
import '../telas/recuperar_senha.dart';

class GoSchoolApp extends StatelessWidget {
  const GoSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoSchool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaLogin(),
        '/selecao-perfil': (context) => const TelaSelecaoPerfil(),
        '/cadastro': (context) => const TelaCadastro(),
        '/recuperar-senha': (context) => const TelaRecuperarSenha(),
      },
    );
  }
}