import 'package:flutter/material.dart';

/// Envolve [child] com uma animação de pulsação contínua enquanto [ativo]
/// for true — usado para chamar atenção para uma ação pendente (ex: "cadastre
/// seu primeiro filho"). Quando [ativo] é false, renderiza [child] parado.
class Pulsante extends StatefulWidget {
  final Widget child;
  final bool ativo;

  const Pulsante({super.key, required this.child, this.ativo = true});

  @override
  State<Pulsante> createState() => _PulsanteState();
}

class _PulsanteState extends State<Pulsante> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _escala = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.ativo) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Pulsante oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ativo && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.ativo) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.ativo) return widget.child;
    return AnimatedBuilder(
      animation: _escala,
      builder: (context, child) => Transform.scale(scale: _escala.value, child: child),
      child: widget.child,
    );
  }
}
