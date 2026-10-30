import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardTransporteAndamento extends StatelessWidget {
  final VoidCallback? onTap;

  const CardTransporteAndamento({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppCores.azulPrincipal.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1)),
          boxShadow: [
            BoxShadow(
              color: AppCores.azulPrincipal.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppCores.azulClaro, AppCores.azulPrincipal],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppCores.azulPrincipal.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transporte em andamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppCores.azulPrincipal,
                    ),
                  ),
                  Text(
                    'Acompanhe o percurso da sua criança em tempo real.',
                    style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
}