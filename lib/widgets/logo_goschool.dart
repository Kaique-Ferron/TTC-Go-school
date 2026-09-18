import 'package:flutter/material.dart';

/// Logo do GoSchool. Tenta carregar a imagem real (assets/logo.png); se o
/// arquivo ainda não existir no projeto, cai graciosamente para um logo em
/// texto (sem quebrar o app).
class LogoGoSchool extends StatelessWidget {
  final double fontSize;
  final double imageHeight;
  final bool corClara; // true = para uso sobre fundo escuro (ex: header com gradiente)

  const LogoGoSchool({
    super.key,
    this.fontSize = 28.0,
    this.imageHeight = 38,
    this.corClara = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: imageHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _logoTexto(),
    );
  }

  Widget _logoTexto() {
    const azulPrincipal = Color(0xFF1D58E2);
    const azulEscuro = Color(0xFF0F2B7A);
    final corGo = corClara ? Colors.white : azulPrincipal;
    final corSchool = corClara ? Colors.white70 : azulEscuro;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'GO',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: corGo,
                ),
              ),
              const WidgetSpan(child: SizedBox(width: 4)),
              TextSpan(
                text: 'SCHOOL',
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: corSchool,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
