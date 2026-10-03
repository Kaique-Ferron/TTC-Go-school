import 'package:flutter/material.dart';
import '../models/motorista_model.dart';

/// Card reutilizável para exibir um motorista na lista de "Motoristas Disponíveis".
class MotoristaCard extends StatelessWidget {
  final Motorista motorista;
  final VoidCallback? onTap;

  const MotoristaCard({super.key, required this.motorista, this.onTap});

  // Estilos centralizados para facilitar a manutenção visual
  static const Color _primaryColor = Color(0xFF1D58E2);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _backgroundColorAvatar = Color(0xFFE8EEFC);

  static const TextStyle _nameTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _textColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar do motorista
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _backgroundColorAvatar,
                  backgroundImage: motorista.fotoPerfil.isNotEmpty
                      ? NetworkImage(motorista.fotoPerfil)
                      : null,
                  child: motorista.fotoPerfil.isEmpty
                      ? const Icon(Icons.person, size: 30, color: _primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Informações e detalhes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(motorista.nome, style: _nameTextStyle),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        children: [
                          _buildDetailItem(Icons.check_circle, Colors.green, '${motorista.corridas} corridas'),
                          _buildDetailItem(Icons.access_time_filled, const Color(0xFFFFC107), motorista.tempo),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildDetailItem(
                        Icons.badge,
                        _primaryColor,
                        'Registro ${motorista.crm}',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
                
                // Ícone de navegação
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Componente auxiliar estilizado para os detalhes do motorista
  Widget _buildDetailItem(IconData icon, Color color, String text, {bool isHighlighted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isHighlighted ? color : Colors.grey[600],
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}