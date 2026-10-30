import 'package:flutter/material.dart';
import '../theme/cores.dart';

/// Selo circular colorido por trás de um ícone — usado em títulos de card e
/// linhas de lista no lugar do ícone "cru" (cinza, sem fundo) que era usado
/// antes. Dá cor onde antes só tinha forma.
class BadgeIcone extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final double tamanho;

  const BadgeIcone({
    super.key,
    required this.icone,
    required this.cor,
    this.tamanho = 26,
  });

  @override
  Widget build(BuildContext context) {
    final corLegivel = AppCores.corIconeLegivel(context, cor);
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: corLegivel.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tamanho * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icone, size: tamanho * 0.56, color: corLegivel),
    );
  }
}
