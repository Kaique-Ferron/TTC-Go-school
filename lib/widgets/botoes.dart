import 'package:flutter/material.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback onPressed;
  final Color cor;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.cor = const Color(0xFF1D58E2),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icone != null) ...[
              Icon(icone, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeletorPerfilTab extends StatelessWidget {
  final String perfilSelecionado; // 'Responsável' ou 'Motorista'
  final ValueChanged<String> onChanged;

  const SeletorPerfilTab({
    super.key,
    required this.perfilSelecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isResponsavel = perfilSelecionado == 'Responsável';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('Responsável'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isResponsavel ? const Color(0xFF1D58E2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: isResponsavel ? Colors.white : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Responsável',
                      style: TextStyle(
                        color: isResponsavel ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('Motorista'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isResponsavel ? const Color(0xFFFF5C00) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: !isResponsavel ? Colors.white : const Color(0xFFFF5C00),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Motorista',
                      style: TextStyle(
                        color: !isResponsavel ? Colors.white : const Color(0xFFFF5C00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}