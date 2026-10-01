import 'package:flutter/material.dart';

<<<<<<< HEAD
/// Logo do GoSchool. Tenta carregar a imagem real (assets/logo.png); se o
=======
/// Logo do GoSchool. Tenta carregar a imagem real (assets/logo.jpg); se o
>>>>>>> master
/// arquivo ainda não existir no projeto, cai graciosamente para um logo em
/// texto (sem quebrar o app).
class LogoGoSchool extends StatelessWidget {
  final double fontSize;
  final double imageHeight;
  final bool corClara; // true = para uso sobre fundo escuro (ex: header com gradiente)

  const LogoGoSchool({
    super.key,
    this.fontSize = 28.0,
<<<<<<< HEAD
    this.imageHeight = 38,
=======
    this.imageHeight = 64,
>>>>>>> master
    this.corClara = false,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Image.asset(
      'assets/logo.png',
      height: imageHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _logoTexto(),
    );
=======
    final imagem = Image.asset(
      'assets/logo.jpg',
      height: imageHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => _logoTexto(),
    );

    // A imagem é um .jpg com fundo branco sólido (sem transparência). Sobre
    // fundos escuros (corClara), colocamos em uma "etiqueta" branca
    // arredondada para o fundo branco parecer intencional, não um bug.
    if (!corClara) return imagem;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imagem,
    );
>>>>>>> master
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
