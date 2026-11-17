import 'package:flutter/material.dart';

class LogoGoSchool extends StatelessWidget {
  final double fontSize;
  final double imageHeight;
  final bool corClara;

  const LogoGoSchool({
    super.key,
    this.fontSize = 34.0,
    this.imageHeight = 77,
    this.corClara = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imageHeight,
      height: imageHeight,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(imageHeight * 0.1),
        child: Image.asset(
          'assets/logo.jpg',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => _logoTexto(),
        ),
      ),
    );
  }

  Widget _logoTexto() {
    return Text(
      'GS',
      style: TextStyle(
        fontSize: fontSize * 0.55,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: const Color(0xFF1D58E2),
      ),
    );
  }
}
