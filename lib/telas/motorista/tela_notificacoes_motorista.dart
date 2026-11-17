import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/conversa_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import '../../widgets/shell_motorista.dart';
import '../chat/tela_chat.dart';

/// Central de notificações do motorista. Em vez de uma lista inventada,
/// junta dois eventos reais que já existem no Firestore: conversas com
/// atividade recente e novas contratações recebidas — ordenados por data,
/// mais recente primeiro.
class TelaNotificacoesMotorista extends StatelessWidget {
  const TelaNotificacoesMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Utilizador não autenticado.')),
      );
    }

    return ShellMotorista(
      itemSelecionado: 'Notificações',
      builder: (context) => _ConteudoNotificacoes(uid: uid),
    );
  }
}

class _ItemNotificacao {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final DateTime? quando;
  final VoidCallback? aoTocar;

  const _ItemNotificacao({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.subtitulo,
    required this.quando,
    this.aoTocar,
  });
}

class _ConteudoNotificacoes extends StatelessWidget {
  final String uid;

  const _ConteudoNotificacoes({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversa>>(
      stream: FirestoreService.instance.conversasStream(uid),
      builder: (context, snapshotConversas) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.contratacoesRecebidasStream(uid),
          builder: (context, snapshotContratacoes) {
            if (snapshotConversas.connectionState == ConnectionState.waiting ||
                snapshotContratacoes.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final itens = <_ItemNotificacao>[
              for (final conversa in snapshotConversas.data ?? <Conversa>[])
                _ItemNotificacao(
                  icone: Icons.chat_bubble_outline,
                  cor: AppCores.azulPrincipal,
                  titulo: conversa.outroNome(uid),
                  subtitulo: conversa.ultimaMensagem.isEmpty ? 'Conversa iniciada.' : conversa.ultimaMensagem,
                  quando: conversa.ultimaMensagemEm,
                  aoTocar: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaChat(
                        conversaId: conversa.id,
                        meuUid: uid,
                        outroUid: conversa.outroUid(uid),
                        outroNome: conversa.outroNome(uid),
                      ),
                    ),
                  ),
                ),
              for (final dados in snapshotContratacoes.data ?? <Map<String, dynamic>>[])
                _ItemNotificacao(
                  icone: Icons.handshake_outlined,
                  cor: AppCores.verde,
                  titulo: '${(dados['responsavelNome'] as String?)?.isNotEmpty == true ? dados['responsavelNome'] : 'Um responsável'} contratou seu serviço',
                  subtitulo: _resumoContratacao(dados),
                  quando: (dados['contratadoEm'] as Timestamp?)?.toDate(),
                ),
            ]..sort((a, b) {
                if (a.quando == null) return 1;
                if (b.quando == null) return -1;
                return b.quando!.compareTo(a.quando!);
              });

            if (itens.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 44, color: AppCores.textoSecundario(context)),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma notificação por aqui ainda.',
                        style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Novas mensagens e contratações vão aparecer aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: itens.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildItem(context, itens[index]),
            );
          },
        );
      },
    );
  }

  String _resumoContratacao(Map<String, dynamic> dados) {
    final periodo = (dados['periodo'] as String?) ?? '';
    final filhosNomes = (dados['filhosNomes'] as List?)?.cast<String>() ?? [];
    final partes = [
      if (periodo.isNotEmpty) periodo,
      if (filhosNomes.isNotEmpty) filhosNomes.join(', '),
    ];
    return partes.isEmpty ? 'Nova contratação.' : partes.join(' · ');
  }

  Widget _buildItem(BuildContext context, _ItemNotificacao item) {
    return InkWell(
      onTap: item.aoTocar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppCores.superficie(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppCores.borda(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: item.cor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(item.icone, size: 18, color: item.cor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titulo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppCores.textoPrincipal(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitulo,
                    style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (item.quando != null) ...[
              const SizedBox(width: 8),
              Text(
                _formatarQuando(item.quando!),
                style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarQuando(DateTime data) {
    final agora = DateTime.now();
    final mesmoDia = agora.year == data.year && agora.month == data.month && agora.day == data.day;
    if (mesmoDia) {
      return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    }
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }
}
