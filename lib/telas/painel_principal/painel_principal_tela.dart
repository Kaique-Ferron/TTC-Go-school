import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../theme/cores.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/nav_inferior_responsavel.dart';
import '../../widgets/card_transporte_andamento.dart';
import '../../widgets/card_acompanhar_rota.dart';
import '../../widgets/card_status_filho.dart';
import '../../widgets/card_motorista_rota.dart';
import '../../widgets/card_avisos_importantes.dart';

class PainelPrincipalTela extends StatelessWidget {
  const PainelPrincipalTela({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    if (!logado) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: const Text('Sessão expirada. Toque para fazer login novamente.'),
          ),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Painel Principal'),
        backgroundColor: const Color(0xFF0F172A), // Topo escuro azul conforme protótipo
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // BOTÃO DE 3 RISCOS / PONTIHNOS HABILITADO
      drawer: const NavbarResponsavel(itemSelecionado: 'Início'),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Início'),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
        builder: (context, snapshotUser) {
          final dadosUsuario = snapshotUser.data?.data();
          final String nomeResponsavel = (dadosUsuario?['nome'] as String?)?.split(' ').first ?? 'Responsável';

          return StreamBuilder<List<Filho>>(
            stream: FirestoreService.instance.filhosStream(uid),
            builder: (context, snapshotFilhos) {
              final filhos = snapshotFilhos.data ?? [];
              final String nomeFilho = filhos.isNotEmpty ? filhos.first.nome : 'Ana Clara';
              final String idadeEAno = filhos.isNotEmpty ? filhos.first.idadeEAno : '8 anos • 3º ano';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saudação com o nome real lido do Firebase
                    Text(
                      'Olá, $nomeResponsavel! 👋',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                    ),
                    Text(
                      'Terça-feira, 21 de outubro',
                      style: TextStyle(fontSize: 13, color: AppCores.textoSecundario(context)),
                    ),
                    const SizedBox(height: 20),

                    // 1. Card Transporte em Andamento
                    CardTransporteAndamento(
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),

                    // 2. Card Acompanhar Rota (com mapa)
                    CardAcompanharRota(
                      onVerDetalhes: () {},
                    ),
                    const SizedBox(height: 16),

                    // 3. Card Status do Filho
                    CardStatusFilho(
                      nomeFilho: nomeFilho,
                      idadeEAno: idadeEAno,
                    ),
                    const SizedBox(height: 16),

                    // 4. Card Motorista em Rota
                    CardMotoristaRota(
                      nomeMotorista: 'Carlos Henrique',
                      onConversar: () => Navigator.pushNamed(context, '/chat'),
                      onLigar: () {},
                    ),
                    const SizedBox(height: 16),

                    // 5. Avisos Importantes
                    const CardAvisosImportantes(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}