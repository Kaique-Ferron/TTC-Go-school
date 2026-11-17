import 'package:flutter/material.dart';
import '../theme/cores.dart';
import 'avaliacao_media.dart';

class CardMotoristaRota extends StatelessWidget {
  final String motoristaUid;
  final String nomeMotorista;
  final String veiculoEPlaca;
  final VoidCallback onConversar;

  const CardMotoristaRota({
    super.key,
    required this.motoristaUid,
    required this.nomeMotorista,
    this.veiculoEPlaca = '',
    required this.onConversar,
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
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppCores.azulPrincipal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeMotorista,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AvaliacaoMedia(motoristaUid: motoristaUid, iconSize: 12, fontSize: 11),
                    if (veiculoEPlaca.isNotEmpty)
                      Text(
                        veiculoEPlaca,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppCores.textoSecundario(context),
                        ),
                      ),
                    Row(
                      children: const [
                        Icon(Icons.verified, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Motorista contratado',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppCores.textoSecundario(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConversar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.azulPrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Conversar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
