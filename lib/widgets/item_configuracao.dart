import 'package:flutter/material.dart';
import '../theme/cores.dart';

class ItemConfiguracaoSwitch extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const ItemConfiguracaoSwitch({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: valor,
            activeColor: AppCores.azulPrincipal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}