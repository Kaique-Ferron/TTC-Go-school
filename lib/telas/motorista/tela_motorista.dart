import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/motorista_model.dart';
import '../../services/auth_service.dart';
import '../../services/localizacao_service.dart';
import '../../theme/cores.dart';
import '../../widgets/badge_icone.dart';
import '../../widgets/cartao_elevado.dart';
import '../../widgets/foto_perfil_provider.dart';
import '../../widgets/shell_motorista.dart';
import '../chat/tela_conversas.dart';
import 'tela_chamada.dart';
import 'tela_financas_motorista.dart';
import 'tela_perfil_motorista.dart';
import 'tela_rota.dart';

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
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Dados do motorista não encontrados.')),
          );
        }

        final dadosMap = snapshot.data!.data() ?? {};
        final Motorista motorista = Motorista.fromMap(dadosMap);

        final passageiros = dadosMap['passageiros'] as String? ?? '15';
        final rotasAtivas = dadosMap['rotasAtivas'] as String? ?? '2';
        final avaliacao = dadosMap['avaliacao'] as String? ?? '4,9/5';

        return ShellMotorista(
          itemSelecionado: 'Painel Principal',
          builder: (context) => _buildConteudo(
            context,
            motorista: motorista,
            passageiros: passageiros,
            rotasAtivas: rotasAtivas,
            avaliacao: avaliacao,
          ),
        );
      },
    );
  }

  Widget _buildConteudo(
    BuildContext context, {
    required Motorista motorista,
    required String passageiros,
    required String rotasAtivas,
    required String avaliacao,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 850;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faixa em destaque (gradiente laranja) só no Painel
              // Principal — pra ficar visualmente óbvio que essa é a tela
              // de "painel do dia", bem diferente do Meu Perfil (fundo
              // branco comum, de ficha cadastral).
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 18, vertical: isWide ? 24 : 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppCores.laranjaMotorista, AppCores.laranjaClaro],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppCores.laranjaMotorista.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${motorista.nome.isEmpty ? 'motorista' : motorista.nome.split(' ')[0]} 👋',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Esse é o seu painel — rotas, chamada e finanças, tudo aqui.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: Colors.white),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notificações chegam em breve.')),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPerfilMotorista())),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            backgroundImage: fotoPerfilProvider(
                              motorista.fotoPerfil,
                            ),
                            child: motorista.fotoPerfil.isEmpty
                                ? Text(
                                    motorista.nome.isNotEmpty
                                        ? motorista.nome[0]
                                        : 'C',
                                    style: const TextStyle(
                                      color: AppCores.laranjaMotorista,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isWide ? 32 : 24),

              _buildCardStatus(context, rotasAtivas),
              const SizedBox(height: 24),

              _buildAcoesRapidas(context, isWide),
              const SizedBox(height: 24),

              // Agenda + Resumo da atividade
              Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildCardAgenda(context),
                  ),
                  SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 20),
                  Expanded(
                    flex: isWide ? 1 : 0,
                    child: _buildCardResumo(
                      context,
                      motorista,
                      passageiros,
                      rotasAtivas,
                      avaliacao,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Card de status no topo do painel, no espírito do app de motorista do
  /// Uber: mostra se o motorista está "Em rota" agora (reflete o GPS real
  /// de [LocalizacaoService], ligado em "Minhas Rotas") e dá o atalho mais
  /// importante da tela — continuar pra lá.
  Widget _buildCardStatus(BuildContext context, String rotasAtivas) {
    final emRota = LocalizacaoService.instance.emAndamento;
    final corStatus = emRota ? Colors.green : AppCores.laranjaMotorista;

    return CartaoElevado(
      corSombra: corStatus,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: corStatus,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: corStatus.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emRota ? 'Você está em rota agora' : 'Pronto pra começar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppCores.textoPrincipal(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  emRota
                      ? 'Sua localização está sendo compartilhada com os responsáveis.'
                      : '$rotasAtivas rota(s) ativa(s) te esperando.',
                  style: TextStyle(fontSize: 13, color: AppCores.textoSecundario(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: corStatus,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaRota())),
            icon: Icon(emRota ? Icons.alt_route : Icons.play_arrow),
            label: Text(emRota ? 'Ver rota' : 'Iniciar rota'),
          ),
        ],
      ),
    );
  }

  /// Linha de atalhos coloridos (estilo grade de ações do app do Uber
  /// Driver) pras telas mais usadas pelo motorista, direto do painel.
  Widget _buildAcoesRapidas(BuildContext context, bool isWide) {
    final acoes = [
      (Icons.alt_route, 'Minhas Rotas', AppCores.laranjaMotorista, () => const TelaRota()),
      (Icons.how_to_reg_outlined, 'Chamada', Colors.green, () => const TelaChamada()),
      (Icons.payments_outlined, 'Finanças', Colors.blueGrey, () => const TelaFinancasMotorista()),
      (Icons.chat_bubble_outline, 'Mensagens', AppCores.azulPrincipal, () => const TelaConversas()),
    ];

    return Row(
      children: acoes
          .map(
            (acao) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: acao == acoes.last ? 0 : (isWide ? 16 : 8)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => acao.$4())),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: isWide ? 18 : 12),
                    decoration: BoxDecoration(
                      color: AppCores.superficie(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppCores.borda(context)),
                    ),
                    child: Column(
                      children: [
                        BadgeIcone(icone: acao.$1, cor: acao.$3, tamanho: isWide ? 40 : 32),
                        const SizedBox(height: 8),
                        Text(
                          acao.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isWide ? 13 : 11,
                            fontWeight: FontWeight.w600,
                            color: AppCores.textoPrincipal(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCardAgenda(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppCores.textoPrincipal(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Minha agenda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: AppCores.fundo(context),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.wb_sunny_outlined,
                color: Colors.orange,
                size: 28,
              ),
              title: Text(
                'Manhã',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
              subtitle: Text(
                '07:00 - 12:00',
                style: TextStyle(color: AppCores.textoSecundario(context)),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppCores.textoSecundario(context),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaRota())),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppCores.fundo(context),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(
                Icons.nights_stay_outlined,
                color: Colors.blue,
                size: 28,
              ),
              title: Text(
                'Tarde',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
              subtitle: Text(
                '13:00 - 18:00',
                style: TextStyle(color: AppCores.textoSecundario(context)),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppCores.textoSecundario(context),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaRota())),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppCores.laranjaMotorista),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaRota())),
              icon: const Icon(Icons.alt_route, color: AppCores.laranjaMotorista),
              label: const Text(
                'Ver minhas rotas',
                style: TextStyle(
                  color: AppCores.laranjaMotorista,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardResumo(
    BuildContext context,
    Motorista motorista,
    String passageiros,
    String rotasAtivas,
    String avaliacao,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF1D58E2)),
              const SizedBox(width: 8),
              Text(
                'Resumo da atividade',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildResumoItem(
                context,
                Icons.alt_route,
                'Rotas ativas',
                rotasAtivas,
                const Color(0xFF1D58E2),
              ),
              _buildResumoItem(
                context,
                Icons.group_outlined,
                'Alunos transportados',
                passageiros,
                Colors.blueGrey,
              ),
              _buildResumoItem(
                context,
                Icons.directions_bus_outlined,
                'Viagens concluídas',
                motorista.corridas,
                Colors.green,
              ),
              _buildResumoItem(
                context,
                Icons.star_outline,
                'Avaliação',
                avaliacao,
                Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(
    BuildContext context,
    IconData icon,
    String titulo,
    String valor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.fundo(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppCores.textoSecundario(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppCores.textoPrincipal(context),
            ),
          ),
        ],
      ),
    );
  }
}
