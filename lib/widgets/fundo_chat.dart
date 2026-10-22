import 'package:flutter/material.dart';
import '../theme/cores.dart';

/// Fundo decorativo da tela de chat — mesma ideia do "papel de parede" do
/// WhatsApp (padrão repetido e bem sutil atrás das mensagens), só que com
/// os ícones e as duas cores de marca do GoSchool (azul do Responsável,
/// laranja do Motorista) em vez de doodles genéricos.
class FundoChat extends StatelessWidget {
  const FundoChat({super.key});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: ColoredBox(
        color: AppCores.fundo(context),
        child: CustomPaint(
          painter: _PadraoGoSchool(
            corAzul: AppCores.azulPrincipal.withValues(
              alpha: escuro ? 0.28 : 0.20,
            ),
            corLaranja: AppCores.laranjaMotorista.withValues(
              alpha: escuro ? 0.28 : 0.20,
            ),
          ),
        ),
      ),
    );
  }
}

class _PadraoGoSchool extends CustomPainter {
  final Color corAzul;
  final Color corLaranja;

  _PadraoGoSchool({required this.corAzul, required this.corLaranja});

  static const _icones = [
    Icons.directions_bus_rounded,
    Icons.route_outlined,
    Icons.school_outlined,
    Icons.favorite_outline,
  ];
  static const _espacamento = 56.0;
  static const _tamanhoIcone = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    var linha = 0;
    for (
      double y = -_espacamento;
      y < size.height + _espacamento;
      y += _espacamento
    ) {
      // Linhas alternadas deslocadas na horizontal — igual ao padrão em
      // "tijolo" do papel de parede do WhatsApp, pra não ficar numa grade
      // óbvia de linhas retas.
      final deslocamento = (linha.isEven) ? 0.0 : _espacamento / 2;
      var coluna = 0;
      for (
        double x = -_espacamento;
        x < size.width + _espacamento;
        x += _espacamento
      ) {
        final icone = _icones[(linha + coluna) % _icones.length];
        final cor = (linha + coluna).isEven ? corAzul : corLaranja;
        _desenharIcone(canvas, icone, Offset(x + deslocamento, y), cor);
        coluna++;
      }
      linha++;
    }
  }

  void _desenharIcone(
    Canvas canvas,
    IconData icone,
    Offset posicao,
    Color cor,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icone.codePoint),
        style: TextStyle(
          fontSize: _tamanhoIcone,
          fontFamily: icone.fontFamily,
          package: icone.fontPackage,
          color: cor,
        ),
      )
      ..layout();
    textPainter.paint(canvas, posicao);
  }

  @override
  bool shouldRepaint(covariant _PadraoGoSchool oldDelegate) =>
      oldDelegate.corAzul != corAzul || oldDelegate.corLaranja != corLaranja;
}
