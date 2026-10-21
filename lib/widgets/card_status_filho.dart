import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardStatusFilho extends StatelessWidget {
  final String nomeFilho;
  final String idadeEAno;
  final String statusAtual;

  const CardStatusFilho({
    super.key,
    required this.nomeFilho,
    required this.idadeEAno,
    this.statusAtual = 'Aguardando',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE8F0FE),
                child: Icon(Icons.person, size: 28, color: AppCores.azulPrincipal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nomeFilho, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(idadeEAno, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(statusAtual, style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPasso('Aguardando\nembarque', '07:20', true),
              _buildPasso('Embarcou', '07:40', false),
              _buildPasso('A caminho', '08:00', false),
              _buildPasso('Chegou na\nescola', '—', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasso(String texto, String hora, bool ativo) {
    return Column(
      children: [
        Icon(
          ativo ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: ativo ? Colors.amber : Colors.grey.shade300,
        ),
        const SizedBox(height: 4),
        Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700)),
        Text(hora, style: TextStyle(fontSize: 9.5, color: ativo ? AppCores.azulPrincipal : Colors.grey)),
      ],
    );
  }
}