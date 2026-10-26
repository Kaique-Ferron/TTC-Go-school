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
import '../chat/tela_chat.dart';

class PainelPrincipalTela extends StatelessWidget {
  const PainelPrincipalTela({super.key});

  static const _diasDaSemana = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  String get _dataDeHoje {
    final agora = DateTime.now();
    final dia = _diasDaSemana[agora.weekday - 1];
    return '${dia[0].toUpperCase()}${dia.substring(1)}, ${agora.day} de ${_meses[agora.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    if (!logado) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            child: const Text(
              'Sessão expirada. Toque para fazer login novamente.',
            ),
          ),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Painel Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),

      // BOTÃO DE 3 RISCOS / PONTIHNOS HABILITADO
      drawer: const NavbarResponsavel(itemSelecionado: 'Início'),
      bottomNavigationBar: const NavInferiorResponsavel(
        abaSelecionada: 'Início',
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshotUser) {
          final dadosUsuario = snapshotUser.data?.data();
          final String nomeResponsavel =
              (dadosUsuario?['nome'] as String?)?.split(' ').first ??
              'Responsável';

          return StreamBuilder<List<Filho>>(
            stream: FirestoreService.instance.filhosStream(uid),
            builder: (context, snapshotFilhos) {
              final filhos = snapshotFilhos.data ?? [];
              final String nomeFilho = filhos.isNotEmpty
                  ? filhos.first.nome
                  : 'Ana Clara';
              final String idadeEAno = filhos.isNotEmpty
                  ? filhos.first.idadeEAno
                  : '8 anos • 3º ano';
              final String escolaFilho = filhos.isNotEmpty ? filhos.first.escola : '';
              final String horarioFilho = filhos.isNotEmpty ? filhos.first.horario : '';
              final double? casaLat = (dadosUsuario?['casa_lat'] as num?)?.toDouble();
              final double? casaLng = (dadosUsuario?['casa_lng'] as num?)?.toDouble();
              final String casaEndereco =
                  (dadosUsuario?['casa_endereco'] as String?)?.trim().isNotEmpty == true
                      ? dadosUsuario!['casa_endereco'] as String
                      : (dadosUsuario?['endereco'] as String?) ?? '';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saudação com o nome real lido do Firebase
                    Text(
                      'Olá, $nomeResponsavel! 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppCores.textoPrincipal(context),
                      ),
                    ),
                    Text(
                      _dataDeHoje,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppCores.textoSecundario(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Card Transporte em Andamento
                    CardTransporteAndamento(onTap: () {}),
                    const SizedBox(height: 16),

                    // 2. Card Acompanhar Rota (com mapa real)
                    CardAcompanharRota(
                      latitude: casaLat,
                      longitude: casaLng,
                      endereco: casaEndereco,
                      escola: escolaFilho,
                      horario: horarioFilho,
                      onVerDetalhes: () {},
                    ),
                    const SizedBox(height: 16),

                    // 3. Card Status do Filho
                    CardStatusFilho(nomeFilho: nomeFilho, idadeEAno: idadeEAno),
                    const SizedBox(height: 16),

                    // 4. Card Motorista contratado (dados reais da contratação ativa)
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: FirestoreService.instance.contratacaoAtivaStream(uid),
                      builder: (context, snapshotContratacao) {
                        final contratacao = snapshotContratacao.data;
                        if (contratacao == null) return const SizedBox.shrink();

                        final motoristaUid = (contratacao['motoristaUid'] as String?) ?? '';
                        final motoristaNome = (contratacao['motoristaNome'] as String?) ?? 'Motorista';
                        final veiculo = (contratacao['motoristaVeiculo'] as String?) ?? '';
                        final placa = (contratacao['motoristaPlaca'] as String?) ?? '';
                        final veiculoEPlaca = [
                          if (veiculo.isNotEmpty) veiculo,
                          if (placa.isNotEmpty) 'Placa: $placa',
                        ].join(' • ');

                        return CardMotoristaRota(
                          motoristaUid: motoristaUid,
                          nomeMotorista: motoristaNome,
                          veiculoEPlaca: veiculoEPlaca,
                          onConversar: () async {
                            final conversaId = await FirestoreService.instance.obterOuCriarConversa(
                              meuUid: uid,
                              meuNome: nomeResponsavel,
                              outroUid: motoristaUid,
                              outroNome: motoristaNome,
                            );
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TelaChat(
                                  conversaId: conversaId,
                                  meuUid: uid,
                                  outroUid: motoristaUid,
                                  outroNome: motoristaNome,
                                ),
                              ),
                            );
                          },
                        );
                      },
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
