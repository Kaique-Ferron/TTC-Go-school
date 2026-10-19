import 'package:flutter/material.dart';
import '../../models/mensagem_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';

/// Thread de mensagens de uma conversa entre Responsável e Motorista.
class TelaChat extends StatefulWidget {
  final String conversaId;
  final String meuUid;
  final String outroNome;

  const TelaChat({
    super.key,
    required this.conversaId,
    required this.meuUid,
    required this.outroNome,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _enviando = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    _controller.clear();
    try {
      await FirestoreService.instance.enviarMensagem(
        conversaId: widget.conversaId,
        remetenteUid: widget.meuUid,
        texto: texto,
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(widget.outroNome),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              stream: FirestoreService.instance.mensagensStream(widget.conversaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensagens = snapshot.data ?? [];
                if (mensagens.isEmpty) {
                  return Center(
                    child: Text(
                      'Diga olá para ${widget.outroNome}!',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final mensagem = mensagens[mensagens.length - 1 - index];
                    final minha = mensagem.enviadaPor(widget.meuUid);
                    return _buildBalao(mensagem, minha);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        filled: true,
                        fillColor: const Color(0xFFF1F3F7),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppCores.azulPrincipal,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _enviando ? null : _enviar,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _enviando
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalao(Mensagem mensagem, bool minha) {
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: minha ? AppCores.azulPrincipal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(minha ? 16 : 4),
            bottomRight: Radius.circular(minha ? 4 : 16),
          ),
          border: minha ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem.texto,
              style: TextStyle(color: minha ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${mensagem.enviadaEm.hour.toString().padLeft(2, '0')}:${mensagem.enviadaEm.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: minha ? Colors.white70 : Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
