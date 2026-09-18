import 'package:flutter/material.dart';
import '../models/motorista_model.dart';

/// Card reutilizável para exibir um motorista na lista de "Motoristas Disponíveis".
class MotoristaCard extends StatelessWidget {
  final Motorista motorista;
  final VoidCallback? onTap;

  const MotoristaCard({super.key, required this.motorista, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8EEFC),
              backgroundImage: motorista.fotoPerfil.isNotEmpty ? NetworkImage(motorista.fotoPerfil) : null,
              child: motorista.fotoPerfil.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Color(0xFF1D58E2))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(motorista.nome, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _detalhe(Icons.check_circle, Colors.green, '${motorista.corridas} corridas'),
                      _detalhe(Icons.access_time_filled, const Color(0xFFFFC107), motorista.tempo),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _detalhe(Icons.badge, const Color(0xFF1D58E2), 'Registro ${motorista.crm}', destaque: true),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _detalhe(IconData icone, Color cor, String texto, {bool destaque = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: cor),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11.5,
            color: destaque ? cor : Colors.grey[600],
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
