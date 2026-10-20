import 'package:flutter/material.dart';
import '../../models/conversa_model.dart';
import '../../models/usuario.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import 'tela_chat.dart';
import 'tela_novo_chat.dart';

/// Lista de conversas do usuário logado (Responsável ou Motorista) — mesma
/// tela serve pros dois perfis, já que a conversa é só uma dupla de uids.
/// Enquanto não há nenhuma conversa, mostra direto a lista de contatos
/// possíveis (sem precisar passar por uma tela extra pra chegar lá).
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
          : StreamBuilder<Usuario?>(
              stream: FirestoreService.instance.usuarioStream(uid),
              builder: (context, snapshotUsuario) {
                if (snapshotUsuario.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meuNome = snapshotUsuario.data?.nome ?? '';
                final souMotorista = snapshotUsuario.data?.tipoPerfil == 'motorista';
                final contatosStream = souMotorista
                    ? FirestoreService.instance.meusResponsaveisStream(uid)
                    : FirestoreService.instance.meusMotoristasContratadosStream(uid);
                final contatosTitulo = souMotorista ? 'Meus responsáveis' : 'Meus motoristas';

                return StreamBuilder<List<Conversa>>(
                  stream: FirestoreService.instance.conversasStream(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final conversas = snapshot.data ?? [];

                    // Sem nenhuma conversa ainda: mostra direto quem dá pra
                    // chamar, em vez de um aviso vazio que manda tocar em
                    // outro lugar.
                    if (conversas.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                contatosTitulo,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListaContatos(
                                meuUid: uid,
                                meuNome: meuNome,
                                contatos: contatosStream,
                                mensagemVazia: souMotorista
                                    ? 'Nenhum responsável contratou você ainda.'
                                    : 'Contrate um motorista na aba Serviços pra poder conversar.',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
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
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TelaNovoChat(
                                      titulo: contatosTitulo,
                                      meuUid: uid,
                                      meuNome: meuNome,
                                      contatos: contatosStream,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.add_comment_outlined, color: AppCores.azulPrincipal),
                                label: const Text('Nova conversa', style: TextStyle(color: AppCores.azulPrincipal, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
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
