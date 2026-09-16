import 'package:flutter/material.dart';

/// Cores centrais do app, para não duplicar os mesmos valores hexadecimais
/// em cada tela (login, cadastro, recuperar senha, etc.).
class AppCores {
  AppCores._();

  static const Color azulPrincipal = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  /// Cor associada ao perfil selecionado ('Responsável' ou 'Motorista').
  static Color porPerfil(String perfil) =>
      perfil == 'Responsável' ? azulPrincipal : laranjaMotorista;
}
