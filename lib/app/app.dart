import 'package:flutter/material.dart';
import '../telas/login.dart';
import '../telas/cadastro.dart';

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
        '/cadastro': (context) => const TelaCadastro(),
      },
    );
  }
}