import 'package:flutter/material.dart';
import '../../models/mensagem_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import '../../widgets/dialog_avaliar_motorista.dart';
import '../../widgets/foto_perfil_provider.dart';
import '../../widgets/fundo_chat.dart';

/// Thread de mensagens de uma conversa entre Responsável e Motorista.
class TelaChat extends StatefulWidget {
  final String conversaId;
  final String meuUid;
  final String outroUid;
  final String outroNome;

  const TelaChat({
    super.key,
    required this.conversaId,
    required this.meuUid,
    required this.outroUid,
    required this.outroNome,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _enviando = false;
  bool _souMotorista = false;
  String _outroFoto = '';

  @override
  void initState() {
    super.initState();
    FirestoreService.instance.usuarioStream(widget.meuUid).first.then((
      usuario,
    ) {
      if (mounted)
        setState(() => _souMotorista = usuario?.tipoPerfil == 'motorista');
    });
    if (widget.outroUid.isNotEmpty) {
      // Só o próprio usuário lê seu documento completo (ver firestore.rules)
      // — então essa busca falha por permissão quando o outro participante
      // não sou eu mesmo. catchError evita exceção não tratada; o avatar
      // simplesmente cai no fallback (ícone de pessoa).
      FirestoreService.instance.usuarioStream(widget.outroUid).first.then((
        usuario,
      ) {
        if (mounted) setState(() => _outroFoto = usuario?.fotoPerfil ?? '');
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _abrirAvaliacao() {
    showDialog(
      context: context,
      builder: (_) => DialogAvaliarMotorista(
        motoristaUid: widget.outroUid,
        motoristaNome: widget.outroNome,
      ),
    );
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
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppCores.azulPrincipal.withValues(alpha: 0.12),
              backgroundImage: fotoPerfilProvider(_outroFoto),
              child: _outroFoto.isEmpty
                  ? Text(
                      widget.outroNome.isNotEmpty
                          ? widget.outroNome[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppCores.azulPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.outroNome, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          if (!_souMotorista && widget.outroUid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.star_outline),
              tooltip: 'Avaliar motorista',
              onPressed: _abrirAvaliacao,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const FundoChat(),
                StreamBuilder<List<Mensagem>>(
                  stream: FirestoreService.instance.mensagensStream(
                    widget.conversaId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final mensagens = snapshot.data ?? [];
                    if (mensagens.isEmpty) {
                      return Center(
                        child: Text(
                          'Diga olá para ${widget.outroNome}!',
                          style: TextStyle(
                            color: AppCores.textoSecundario(context),
                            fontSize: 13.5,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final mensagem =
                            mensagens[mensagens.length - 1 - index];
                        final minha = mensagem.enviadaPor(widget.meuUid);
                        return _buildBalao(mensagem, minha);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: AppCores.superficie(context),
                border: Border(top: BorderSide(color: AppCores.borda(context))),
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
                      style: TextStyle(color: AppCores.textoPrincipal(context)),
                      decoration: InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        filled: true,
                        fillColor: AppCores.fundo(context),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
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
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: minha ? AppCores.azulPrincipal : AppCores.superficie(context),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(minha ? 16 : 4),
            bottomRight: Radius.circular(minha ? 4 : 16),
          ),
          border: minha ? null : Border.all(color: AppCores.borda(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem.texto,
              style: TextStyle(
                color: minha ? Colors.white : AppCores.textoPrincipal(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${mensagem.enviadaEm.hour.toString().padLeft(2, '0')}:${mensagem.enviadaEm.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: minha
                    ? Colors.white70
                    : AppCores.textoSecundario(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
