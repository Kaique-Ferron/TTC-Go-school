import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardCartao extends StatelessWidget {
  final String ultimosDigitos;
  final String validade;
  final String titular;
  final bool isPadrao;
  final VoidCallback? onTap;

  const CardCartao({
    super.key,
    required this.ultimosDigitos,
    required this.validade,
    required this.titular,
    this.isPadrao = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppCores.borda(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 28,
          decoration: BoxDecoration(
            color: AppCores.laranjaMotorista,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
        ),
        title: Row(
          children: [
            Text(
              '•••• •••• •••• $ultimosDigitos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppCores.textoPrincipal(context)),
            ),
            if (isPadrao) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Padrão',
                  style: TextStyle(
                    color: Color(0xFF1D58E2),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Venc. $validade • $titular',
          style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: AppCores.textoSecundario(context)),
      ),
    );
  }
}