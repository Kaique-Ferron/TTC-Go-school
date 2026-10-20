import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/contato_chat.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import 'tela_chat.dart';

final _regexLink = RegExp(r'https?://\S+');

/// Lista de contatos pra começar uma conversa — motoristas já contratados
/// (lado do Responsável) ou responsáveis que já contrataram (lado do
/// Motorista). Tocar num contato abre o chat direto. Sem Scaffold próprio
/// pra poder ser usada tanto dentro de [TelaNovoChat] quanto embutida direto
/// no estado vazio de [TelaConversas] (sem precisar de uma tela extra).
class ListaContatos extends StatelessWidget {
  final String meuUid;
  final String meuNome;
  final Stream<List<ContatoChat>> contatos;
  final String mensagemVazia;

  const ListaContatos({
    super.key,
    required this.meuUid,
    required this.meuNome,
    required this.contatos,
    this.mensagemVazia = 'Ninguém por aqui ainda.',
  });

  Future<void> _abrirConversa(BuildContext context, ContatoChat contato) async {
    final conversaId = await FirestoreService.instance.obterOuCriarConversa(
      meuUid: meuUid,
      meuNome: meuNome,
      outroUid: contato.uid,
      outroNome: contato.nome,
    );
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaChat(conversaId: conversaId, meuUid: meuUid, outroNome: contato.nome),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ContatoChat>>(
      stream: contatos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErroContatos(erro: snapshot.error.toString());
        }

        final lista = snapshot.data ?? [];
        if (lista.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search_outlined, size: 44, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    mensagemVazia,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          itemCount: lista.length,
          separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100, indent: 80),
          itemBuilder: (context, index) {
            final contato = lista[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE8EEFC),
                child: Text(
                  contato.nome.isNotEmpty ? contato.nome[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppCores.azulPrincipal, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              title: Text(
                contato.nome.isNotEmpty ? contato.nome : 'Sem nome',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _abrirConversa(context, contato),
            );
          },
        );
      },
    );
  }
}

/// Mostra o erro de carregar os contatos — na maioria das vezes é o
/// Firestore pedindo pra criar um índice de collection group pela primeira
/// vez. O texto do próprio Firestore já vem com o link pronto, só que como
/// texto corrido; aqui ele fica selecionável e tem um botão que copia só o
/// link direto pra área de transferência (resolvendo a dor de "não dá pra
/// copiar da tela do app").
class _ErroContatos extends StatelessWidget {
  final String erro;

  const _ErroContatos({required this.erro});

  @override
  Widget build(BuildContext context) {
    final link = _regexLink.firstMatch(erro)?.group(0);
    final eIndiceFaltando = erro.contains('failed-precondition') || erro.contains('requires an index');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 36),
            const SizedBox(height: 10),
            Text(
              eIndiceFaltando
                  ? 'O Firestore precisa de um índice pra essa consulta (primeira vez só).'
                  : 'Não foi possível carregar os contatos.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            if (link != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiado! Cole numa aba nova do navegador.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppCores.azulPrincipal),
                icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                label: const Text('Copiar link pra criar o índice', style: TextStyle(color: Colors.white)),
              ),
            ],
            const SizedBox(height: 14),
            SelectableText(
              erro,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela própria em volta de [ListaContatos], usada quando o usuário já tem
/// conversas e quer começar mais uma (ícone "Nova conversa" na AppBar).
class TelaNovoChat extends StatelessWidget {
  final String titulo;
  final String meuUid;
  final String meuNome;
  final Stream<List<ContatoChat>> contatos;

  const TelaNovoChat({
    super.key,
    required this.titulo,
    required this.meuUid,
    required this.meuNome,
    required this.contatos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListaContatos(meuUid: meuUid, meuNome: meuNome, contatos: contatos),
    );
  }
}
