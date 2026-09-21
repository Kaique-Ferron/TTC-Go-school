import 'package:flutter/material.dart';

class CardFilho extends StatelessWidget {
  final String nome;
  final String idadeEAno;
  final String escola;
  final String turno;
  final String horario;
  final String status;
  final Color corAcento;
  final VoidCallback? onTap;

  const CardFilho({
    super.key,
    required this.nome,
    required this.idadeEAno,
    required this.escola,
    required this.turno,
    required this.horario,
    this.status = 'Ativo',
    this.corAcento = const Color(0xFF1D58E2),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: corAcento.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(16),
        color: corAcento.withValues(alpha: 0.03),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: corAcento.withValues(alpha: 0.16),
          child: Icon(Icons.person, color: corAcento),
        ),
        title: Row(
          children: [
            Text(
              nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: corAcento.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: corAcento,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(idadeEAno, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(escola, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      turno,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '($horario)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: corAcento),
          ],
        ),
      ),
    );
  }
}
