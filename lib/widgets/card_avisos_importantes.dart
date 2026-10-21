import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardAvisosImportantes extends StatelessWidget {
  const CardAvisosImportantes({super.key});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, size: 18, color: Colors.amber),
                  const SizedBox(width: 6),
                  const Text('Avisos importantes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos', style: TextStyle(fontSize: 12, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildItemAviso(context, 'O motorista saiu para buscar a criança.', '07:32'),
          const Divider(height: 12),
          _buildItemAviso(context, 'Previsão de chegada na escola: 08:15.', '07:20'),
        ],
      ),
    );
  }

  Widget _buildItemAviso(BuildContext context, String mensagem, String hora) {
    return Row(
      children: [
        const Icon(Icons.notifications_outlined, size: 16, color: Colors.amber),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mensagem, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text(hora, style: TextStyle(fontSize: 10, color: AppCores.textoSecundario(context))),
            ],
          ),
        ),
        Icon(Icons.chevron_right, size: 16, color: AppCores.textoSecundario(context)),
      ],
    );
  }
}