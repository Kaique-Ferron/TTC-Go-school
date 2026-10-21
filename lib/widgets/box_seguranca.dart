import 'package:flutter/material.dart';
import '../theme/cores.dart';

class BoxSeguranca extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const BoxSeguranca({
    super.key,
    this.titulo = 'Segurança em primeiro lugar',
    this.subtitulo = 'Seus dados estão protegidos com segurança e criptografia avançada.',
  });

  @override
  Widget build(BuildContext context) {
    const Color azulPrincipal = Color(0xFF1D58E2);
    final bool escuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: escuro ? azulPrincipal.withValues(alpha: 0.14) : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: azulPrincipal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: escuro ? Colors.lightBlue.shade200 : azulPrincipal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: AppCores.textoSecundario(context),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}