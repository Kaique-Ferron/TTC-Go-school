import 'package:flutter/material.dart';

/// Logo do GoSchool, sempre dentro de um selo circular branco — assim funciona
/// igual sobre qualquer fundo (claro ou escuro) sem precisar de transparência
/// na imagem (assets/logo.jpg tem fundo branco sólido mesmo). Se o arquivo
/// ainda não existir no projeto, cai graciosamente para um logo em texto.
class LogoGoSchool extends StatelessWidget {
  final double fontSize;
  final double imageHeight;
  final bool corClara; // true = para uso sobre fundo escuro (ex: header com gradiente)

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

  // Fallback (só usado se assets/logo.jpg não existir): monograma "GS",
  // dimensionado pra caber dentro do selo circular sem transbordar.
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
