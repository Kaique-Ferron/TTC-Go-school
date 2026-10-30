import 'package:flutter/material.dart';
import '../theme/cores.dart';

/// Card com profundidade de verdade (gradiente sutil + sombra colorida),
/// em vez do Container(color: superficie, border: Border.all(borda)) plano
/// usado antes em quase toda tela do Responsável — mesma ideia do painel de
/// design: elevação real, e opcionalmente uma tarja de cor na borda
/// esquerda (`corAcento`) como um segundo jeito de marcar o card, sem
/// pintar ele inteiro.
class CartaoElevado extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? corAcento;
  final Color? corSombra;

  const CartaoElevado({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.corAcento,
    this.corSombra,
  });

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final sombra = corSombra ?? AppCores.azulPrincipal;

    // Border com cor diferente por lado (pra tarja de cor) não pode ter
    // borderRadius — o Flutter rejeita essa combinação (quebra a pintura a
    // cada frame). Por isso a tarja vira uma barrinha separada por cima
    // (Stack), em vez de ser a borda esquerda do Container.
    final corpo = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? [AppCores.superficie(context), AppCores.superficie(context)]
              : const [Colors.white, Color(0xFFFCFDFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppCores.borda(context)),
        boxShadow: [
          BoxShadow(
            color: sombra.withValues(alpha: escuro ? 0.22 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );

    if (corAcento == null) return corpo;

    return Stack(
      children: [
        corpo,
        Positioned(
          left: 0,
          top: 10,
          bottom: 10,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: corAcento,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
