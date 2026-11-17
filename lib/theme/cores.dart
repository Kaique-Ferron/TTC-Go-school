import 'package:flutter/material.dart';

class AppCores {
  AppCores._();

  static const Color azulPrincipal = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  static const Color azulClaro = Color(0xFF3B82F6);
  static const Color azulEscuro = Color(0xFF0F2B7A);
  static const Color laranjaClaro = Color(0xFFFB923C);
  static const Color laranjaEscuro = Color(0xFFC2410C);

  static const Color verde = Color(0xFF16A34A);
  static const Color roxo = Color(0xFF9333EA);
  static const Color rosa = Color(0xFFEC4899);
  static const Color ciano = Color(0xFF0EA5E9);
  static const Color ambar = Color(0xFFF59E0B);

  static Color porPerfil(String perfil) =>
      perfil == 'Responsável' ? azulPrincipal : laranjaMotorista;

  static const List<Color> paletaFilhos = [
    azulPrincipal,
    laranjaMotorista,
    azulClaro,
    laranjaClaro,
    azulEscuro,
    laranjaEscuro,
  ];

  static Color corFilho(int index) => paletaFilhos[index % paletaFilhos.length];

  static Color fundo(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  static Color superficie(BuildContext context) => Theme.of(context).cardColor;

  static Color borda(BuildContext context) => Theme.of(context).dividerColor;

  static Color textoPrincipal(BuildContext context) => Theme.of(context).colorScheme.onSurface;

  static Color textoSecundario(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9AA0A6) : Colors.grey.shade600;

  static Color corIconeLegivel(BuildContext context, Color cor) {
    if (Theme.of(context).brightness != Brightness.dark) return cor;
    if (cor == azulEscuro) return azulClaro;
    if (cor == laranjaEscuro) return laranjaClaro;
    return cor;
  }
}
