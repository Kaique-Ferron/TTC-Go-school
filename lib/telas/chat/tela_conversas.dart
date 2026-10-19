import 'package:flutter/material.dart';
import '../../models/conversa_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import 'tela_chat.dart';

/// Lista de conversas do usuário logado (Responsável ou Motorista) — mesma
/// tela serve pros dois perfis, já que a conversa é só uma dupla de uids.
class TelaConversas extends StatelessWidget {
  const TelaConversas({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(child: Text('Utilizador não autenticado.'))
          : StreamBuilder<List<Conversa>>(
              stream: FirestoreService.instance.conversasStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final conversas = snapshot.data ?? [];
                if (conversas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(color: AppCores.azulPrincipal.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.chat_bubble_outline, size: 40, color: AppCores.azulPrincipal),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma conversa ainda.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Converse com um motorista a partir da aba Serviços.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversas.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100, indent: 80),
                  itemBuilder: (context, index) {
                    final conversa = conversas[index];
                    final outroNome = conversa.outroNome(uid);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE8EEFC),
                        child: Text(
                          outroNome.isNotEmpty ? outroNome[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppCores.azulPrincipal, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      title: Text(outroNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                      subtitle: Text(
                        conversa.ultimaMensagem.isNotEmpty ? conversa.ultimaMensagem : 'Nenhuma mensagem ainda.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: conversa.ultimaMensagemEm == null
                          ? null
                          : Text(_formatarHorario(conversa.ultimaMensagemEm!), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaChat(conversaId: conversa.id, meuUid: uid, outroNome: outroNome),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatarHorario(DateTime data) {
    final agora = DateTime.now();
    final mesmoDia = agora.year == data.year && agora.month == data.month && agora.day == data.day;
    if (mesmoDia) {
      return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    }
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }
}
