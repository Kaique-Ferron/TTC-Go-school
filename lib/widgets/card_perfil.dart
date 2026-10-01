import 'package:flutter/material.dart';

class CardPerfil extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color corAccent;
  final Color iconeBackground;
  final IconData icone;
  final VoidCallback onTap;

  const CardPerfil({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.corAccent,
    required this.iconeBackground,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconeBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: corAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: corAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: corAccent, size: 22),
          ],
        ),
      ),
    );
  }
}