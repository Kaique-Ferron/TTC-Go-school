import 'package:flutter/material.dart';
import 'telas/login.dart';
import 'telas/cadastro.dart';
import 'widgets/botoes.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema TCC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaBoasVindas(),
    );
  }
}

class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone / Logo do Sistema
                const Icon(
                  Icons.shield_outlined,
                  size: 90,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),

                // Nome do App / Sistema
                const Text(
                  'Portal de Acesso',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Descrição curta
                Text(
                  'Gerencie suas atividades e registros com segurança e praticidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),

                // 1. BOTÃO DE LOGIN
                botao(
                  'Entrar',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaLogin(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // 2. BOTÃO DE CADASTRO (Estilizado como ação secundária)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaCadastro(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Criar Nova Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//fef