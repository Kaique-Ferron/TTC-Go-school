import 'package:flutter/material.dart';

/// Cores centrais do app, para não duplicar os mesmos valores hexadecimais
/// em cada tela (login, cadastro, recuperar senha, etc.).
class AppCores {
  AppCores._();

  static const Color azulPrincipal = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

<<<<<<< HEAD
=======
  // Tons adicionais de azul e laranja (cores padrão do app), para dar
  // variedade visual sem introduzir cores fora do tema.
  static const Color azulClaro = Color(0xFF3B82F6);
  static const Color azulEscuro = Color(0xFF0F2B7A);
  static const Color laranjaClaro = Color(0xFFFB923C);
  static const Color laranjaEscuro = Color(0xFFC2410C);

>>>>>>> master
  static const Color verde = Color(0xFF16A34A);
  static const Color roxo = Color(0xFF9333EA);
  static const Color rosa = Color(0xFFEC4899);
  static const Color ciano = Color(0xFF0EA5E9);
  static const Color ambar = Color(0xFFF59E0B);

  /// Cor associada ao perfil selecionado ('Responsável' ou 'Motorista').
  static Color porPerfil(String perfil) =>
      perfil == 'Responsável' ? azulPrincipal : laranjaMotorista;

  /// Paleta usada para distinguir visualmente os cards de cada filho.
<<<<<<< HEAD
  static const List<Color> paletaFilhos = [azulPrincipal, verde, laranjaMotorista, roxo, ciano, rosa];
=======
  /// Mantida apenas em tons de azul e laranja (cores padrão do app).
  static const List<Color> paletaFilhos = [
    azulPrincipal,
    laranjaMotorista,
    azulClaro,
    laranjaClaro,
    azulEscuro,
    laranjaEscuro,
  ];
>>>>>>> master

  static Color corFilho(int index) => paletaFilhos[index % paletaFilhos.length];
}
