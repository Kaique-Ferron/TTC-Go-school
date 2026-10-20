import 'package:flutter/material.dart';
import '../theme/cores.dart';

class ItemConfiguracaoLink extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final Widget? sufixoEspecial;
  final VoidCallback onTap;

  const ItemConfiguracaoLink({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    this.sufixoEspecial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppCores.azulPrincipal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 18, color: AppCores.azulPrincipal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (sufixoEspecial != null) ...[
              sufixoEspecial!,
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}