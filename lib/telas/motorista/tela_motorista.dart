import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class TelaMotorista extends StatelessWidget {
  const TelaMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Utilizador não autenticado.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      // Lemos o documento do utilizador diretamente do Firestore
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Validação de Dados Existentes
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Dados do motorista não encontrados.')),
          );
        }

        // Obtém o mapa de dados diretamente do documento no Firebase
        final dados = snapshot.data!.data() ?? {};

        // Extrai os campos com valores padrão (fallbacks)
        final nome = dados['nome'] as String? ?? 'Motorista';
        final veiculo = dados['veiculo'] as String? ?? 'Veículo não cadastrado';
        final placa = dados['placa'] as String? ?? '---';
        final cnh = dados['cnh'] as String? ?? '---';
        final licenca = dados['licenca'] as String? ?? '---';

        return Scaffold(
          appBar: AppBar(
            title: const Text('GoSchool'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () async {
                  await AuthService.instance.sair();
                },
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SAUDAÇÃO COM NOME REAL
                Text(
                  'Olá, $nome! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Confira suas atividades de hoje.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // CARD DO VEÍCULO E DOCUMENTOS
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Veículo e Documentação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.directions_bus, size: 40),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // NOME DO VEÍCULO
                                  Text(
                                    veiculo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // PLACA
                                  Text(
                                    'Placa: $placa',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const Divider(height: 16),

                                  // CNH E LICENÇA
                                  Text(
                                    'CNH: $cnh',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    'Licença: $licenca',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ROTA DE HOJE
                const Text(
                  'Rota de hoje',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.route),

                            SizedBox(width: 10),

                            Text(
                              'Nenhuma rota definida',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text('Você ainda não possui uma rota para hoje.'),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // A implementar futuramente
                            },
                            child: const Text('Ver rotas'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // BOTÃO INICIAR ROTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // A implementar futuramente
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'INICIAR ROTA',
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

          // MENU INFERIOR
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),

              BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Rotas'),

              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Alunos',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}