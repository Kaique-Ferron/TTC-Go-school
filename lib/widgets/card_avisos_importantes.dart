import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardAvisosImportantes extends StatelessWidget {
  const CardAvisosImportantes({super.key});

  // Lista completa (mockada) mostrada no popup "Ver todos" — as duas
  // primeiras são as mesmas já exibidas no card, só com mais itens de
  // histórico abaixo.
  static const _todosAvisos = [
    ('O motorista saiu para buscar a criança.', '07:32'),
    ('Previsão de chegada na escola: 08:15.', '07:20'),
    ('Criança embarcou com segurança.', '07:10'),
    ('Rota concluída com sucesso.', 'Ontem, 16:40'),
    ('Lembrete: mensalidade vence em 3 dias.', 'Ontem, 09:00'),
  ];

  void _abrirTodosAvisos(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppCores.superficie(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Avisos importantes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppCores.textoPrincipal(dialogContext),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._todosAvisos.map(
                (aviso) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildItemAviso(dialogContext, aviso.$1, aviso.$2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  const Icon(
                    Icons.notifications_active_outlined,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Avisos importantes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _abrirTodosAvisos(context),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildItemAviso(
            context,
            'O motorista saiu para buscar a criança.',
            '07:32',
          ),
          const Divider(height: 12),
          _buildItemAviso(
            context,
            'Previsão de chegada na escola: 08:15.',
            '07:20',
          ),
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
              Text(
                mensagem,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hora,
                style: TextStyle(
                  fontSize: 10,
                  color: AppCores.textoSecundario(context),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: AppCores.textoSecundario(context),
        ),
      ],
    );
  }
}
