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
import '../../widgets/card_clima.dart';
import '../../widgets/logo_goschool.dart';
import '../chat/tela_chat.dart';
import 'tela_detalhes_rota.dart';

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
        title: const Row(
          children: [
            LogoGoSchool(imageHeight: 30),
            SizedBox(width: 10),
            Text('Painel Principal'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),

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

              final filhoComEscola = filhos.where((f) => f.temLocalizacaoEscola);
              final escolaFilho = filhoComEscola.isNotEmpty ? filhoComEscola.first.escola : (filhos.isNotEmpty ? filhos.first.escola : '');
              final double? escolaLat = filhoComEscola.isNotEmpty ? filhoComEscola.first.escolaLat : null;
              final double? escolaLng = filhoComEscola.isNotEmpty ? filhoComEscola.first.escolaLng : null;
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
                    const SizedBox(height: 16),

                    CardClima(lat: casaLat, lng: casaLng),
                    const SizedBox(height: 16),

                    StreamBuilder<Map<String, dynamic>?>(
                      stream: FirestoreService.instance.contratacaoAtivaStream(uid),
                      builder: (context, snapshotContratacao) {
                        final contratacao = snapshotContratacao.data;
                        final motoristaUid = contratacao == null ? null : (contratacao['motoristaUid'] as String?) ?? '';
                        final motoristaNome = (contratacao?['motoristaNome'] as String?) ?? 'Motorista';
                        final veiculo = (contratacao?['motoristaVeiculo'] as String?) ?? '';
                        final placa = (contratacao?['motoristaPlaca'] as String?) ?? '';
                        final veiculoEPlaca = [
                          if (veiculo.isNotEmpty) veiculo,
                          if (placa.isNotEmpty) 'Placa: $placa',
                        ].join(' • ');

                        if (motoristaUid != null && motoristaUid.isNotEmpty) {
                          FirestoreService.instance.registrarResponsavelAtivo(motoristaUid, uid).catchError((_) {});
                        }

                        if (casaLat != null && casaLng != null) {
                          FirestoreService.instance
                              .autoSincronizarLocalizacaoNasContratacoes(uid, lat: casaLat, lng: casaLng, endereco: casaEndereco)
                              .catchError((_) {});
                        }

                        FirestoreService.instance
                            .autoSincronizarEscolasNasContratacoes(uid, filhos)
                            .catchError((_) {});

                        void abrirDetalhes() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TelaDetalhesRota(
                                motoristaUid: motoristaUid,
                                motoristaNome: contratacao == null ? '' : motoristaNome,
                                latitude: casaLat,
                                longitude: casaLng,
                                endereco: casaEndereco,
                                escola: escolaFilho,
                                escolaLat: escolaLat,
                                escolaLng: escolaLng,
                                horario: horarioFilho,
                                veiculoEPlaca: veiculoEPlaca,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [

                            CardTransporteAndamento(onTap: abrirDetalhes),
                            const SizedBox(height: 16),

                            CardAcompanharRota(
                              latitude: casaLat,
                              longitude: casaLng,
                              endereco: casaEndereco,
                              escola: escolaFilho,
                              horario: horarioFilho,
                              motoristaUid: motoristaUid,
                              onVerDetalhes: abrirDetalhes,
                            ),
                            const SizedBox(height: 16),

                            CardStatusFilho(nomeFilho: nomeFilho, idadeEAno: idadeEAno),
                            const SizedBox(height: 16),

                            if (contratacao != null)
                              CardMotoristaRota(
                                motoristaUid: motoristaUid!,
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
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

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
