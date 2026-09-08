import 'package:flutter/material.dart';
import 'campos.dart';

class SecaoMotorista extends StatelessWidget {
  final TextEditingController cnhController;
  final TextEditingController licencaController;
  final TextEditingController placaController;

  const SecaoMotorista({
    super.key,
    required this.cnhController,
    required this.licencaController,
    required this.placaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentação e Veículo (Regulamentação)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),

        // CNH
        CampoTextoCustomizado(
          controller: cnhController,
          hintText: 'Número da CNH (Cat. D/E com EAR)',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 10),

        // Licença / Alvará Escolar
        CampoTextoCustomizado(
          controller: licencaController,
          hintText: 'Nº da Licença / Alvará de Transporte Escolar',
          prefixIcon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 10),

        // Placa do Veículo
        CampoTextoCustomizado(
          controller: placaController,
          hintText: 'Placa da Van / Ônibus (ex: ABC-1234)',
          prefixIcon: Icons.directions_bus_outlined,
        ),
      ],
    );
  }
}