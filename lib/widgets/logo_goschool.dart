import 'package:flutter/material.dart';

class LogoGoSchool extends StatelessWidget {
  final double fontSize;

  const LogoGoSchool({
    super.key,
    this.fontSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    const Color azulPrincipal = Color(0xFF1D58E2);
    const Color azulEscuro = Color(0xFF0F2B7A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  color: azulPrincipal,
                ),
              ),
              const WidgetSpan(child: SizedBox(width: 4)),
              TextSpan(
                text: 'SCHOOL',
                style: TextStyle(
                  fontSize: fontSize * 0.85,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: azulEscuro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}