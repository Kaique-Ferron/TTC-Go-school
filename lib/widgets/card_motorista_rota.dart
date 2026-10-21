import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardMotoristaRota extends StatelessWidget {
  final String nomeMotorista;
  final double avaliacao;
  final int totalAvaliacoes;
  final String veiculoEPlaca;
  final VoidCallback onConversar;
  final VoidCallback onLigar;

  const CardMotoristaRota({
    super.key,
    required this.nomeMotorista,
    this.avaliacao = 4.9,
    this.totalAvaliacoes = 32,
    this.veiculoEPlaca = 'Van Escolar • Placa: FJZ-3H42',
    required this.onConversar,
    required this.onLigar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFEFF6FF),
                child: Icon(Icons.person, size: 30, color: AppCores.azulPrincipal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nomeMotorista, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('$avaliacao ($totalAvaliacoes avaliações)', style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context))),
                      ],
                    ),
                    Text(veiculoEPlaca, style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context))),
                    Row(
                      children: const [
                        CircleAvatar(radius: 3, backgroundColor: Colors.green),
                        SizedBox(width: 4),
                        Text('Em rota', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppCores.textoSecundario(context)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onConversar,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppCores.azulPrincipal),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppCores.azulPrincipal),
                  label: const Text('Conversar', style: TextStyle(color: AppCores.azulPrincipal, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onLigar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCores.azulPrincipal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.phone, size: 16, color: Colors.white),
                  label: const Text('Ligar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}