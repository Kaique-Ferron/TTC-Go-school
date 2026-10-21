import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/cores.dart';

/// Diálogo de avaliação rápida (estrelas + comentário opcional) de um
/// motorista já contratado. Grava em usuarios/{motoristaUid}/avaliacoes.
class DialogAvaliarMotorista extends StatefulWidget {
  final String motoristaUid;
  final String motoristaNome;

  const DialogAvaliarMotorista({
    super.key,
    required this.motoristaUid,
    required this.motoristaNome,
  });

  @override
  State<DialogAvaliarMotorista> createState() => _DialogAvaliarMotoristaState();
}

class _DialogAvaliarMotoristaState extends State<DialogAvaliarMotorista> {
  int _nota = 0;
  final _comentarioController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_nota == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toque numa estrela pra dar uma nota.')),
      );
      return;
    }

    final meuUid = AuthService.instance.uidAtual;
    if (meuUid == null) return;

    setState(() => _enviando = true);
    try {
      final meuUsuario = await FirestoreService.instance.usuarioStream(meuUid).first;
      await FirestoreService.instance.enviarAvaliacao(
        motoristaUid: widget.motoristaUid,
        responsavelUid: meuUid,
        responsavelNome: meuUsuario?.nome ?? '',
        nota: _nota,
        comentario: _comentarioController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação enviada. Obrigado!'), backgroundColor: AppCores.verde),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível enviar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Como foi com ${widget.motoristaNome}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final valor = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _nota = valor),
                  icon: Icon(
                    valor <= _nota ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Comentário (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppCores.azulPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _enviando ? null : _enviar,
                child: _enviando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar avaliação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
