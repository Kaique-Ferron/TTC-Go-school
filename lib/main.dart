import 'package:flutter/material.dart';

// Importe o arquivo da tela que acabamos de criar
import 'telas/landpage/landpage-tela.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go School',
      // Remove a faixa vermelha de "DEBUG" do canto da tela
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: const Color(0xFF1D58E2),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      ),
      // Aqui você define qual tela o app vai abrir primeiro:
      home: const LandpageTela(), 
    );
  }
}