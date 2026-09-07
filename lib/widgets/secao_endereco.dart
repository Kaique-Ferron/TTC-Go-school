import 'package:flutter/material.dart';
import 'campos.dart';

class SecaoEndereco extends StatelessWidget {
  final TextEditingController cepController;
  final TextEditingController ruaController;
  final TextEditingController numeroController;
  final TextEditingController bairroController;
  final bool carregandoCep;

  const SecaoEndereco({
    super.key,
    required this.cepController,
    required this.ruaController,
    required this.numeroController,
    required this.bairroController,
    this.carregandoCep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Endereço',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),

        // Campo CEP
        CampoTextoCustomizado(
          controller: cepController,
          hintText: 'CEP (ex: 01310-100)',
          prefixIcon: Icons.location_on_outlined,
          suffixIcon: carregandoCep 
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null,
        ),
        const SizedBox(height: 10),

        // Rua e Número lado a lado
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CampoTextoCustomizado(
                controller: ruaController,
                hintText: 'Rua / Avenida',
                prefixIcon: Icons.map_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: CampoTextoCustomizado(
                controller: numeroController,
                hintText: 'Nº',
                prefixIcon: Icons.home_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Bairro
        CampoTextoCustomizado(
          controller: bairroController,
          hintText: 'Bairro',
          prefixIcon: Icons.location_city_outlined,
        ),
      ],
    );
  }
}