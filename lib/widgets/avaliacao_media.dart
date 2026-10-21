import 'package:flutter/material.dart';
import '../models/avaliacao_model.dart';
import '../services/firestore_service.dart';
import '../theme/cores.dart';

/// Mostra a nota média real de um motorista (calculada em cima da
/// subcoleção de avaliações) — em vez do texto fixo que existia antes.
/// Usado no card da lista de motoristas e no modal de detalhes.
class AvaliacaoMedia extends StatelessWidget {
  final String motoristaUid;
  final double iconSize;
  final double fontSize;
  final Color? color;

  const AvaliacaoMedia({
    super.key,
    required this.motoristaUid,
    this.iconSize = 14,
    this.fontSize = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final corEstrela = color ?? Colors.amber;

    if (motoristaUid.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, size: iconSize, color: AppCores.textoSecundario(context)),
          const SizedBox(width: 3),
          Text('Sem avaliações', style: TextStyle(fontSize: fontSize, color: AppCores.textoSecundario(context))),
        ],
      );
    }

    return StreamBuilder<List<Avaliacao>>(
      stream: FirestoreService.instance.avaliacoesStream(motoristaUid),
      builder: (context, snapshot) {
        final avaliacoes = snapshot.data ?? [];
        if (avaliacoes.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, size: iconSize, color: AppCores.textoSecundario(context)),
              const SizedBox(width: 3),
              Text('Sem avaliações ainda', style: TextStyle(fontSize: fontSize, color: AppCores.textoSecundario(context))),
            ],
          );
        }

        final media = avaliacoes.map((a) => a.nota).reduce((a, b) => a + b) / avaliacoes.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: iconSize, color: corEstrela),
            const SizedBox(width: 3),
            Text(
              '${media.toStringAsFixed(1)} (${avaliacoes.length})',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}
