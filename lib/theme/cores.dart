import 'package:flutter/material.dart';

/// Cores centrais do app, para não duplicar os mesmos valores hexadecimais
/// em cada tela (login, cadastro, recuperar senha, etc.).
class AppCores {
  AppCores._();

  static const Color azulPrincipal = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  // Tons adicionais de azul e laranja (cores padrão do app), para dar
  // variedade visual sem introduzir cores fora do tema.
  static const Color azulClaro = Color(0xFF3B82F6);
  static const Color azulEscuro = Color(0xFF0F2B7A);
  static const Color laranjaClaro = Color(0xFFFB923C);
  static const Color laranjaEscuro = Color(0xFFC2410C);

  static const Color verde = Color(0xFF16A34A);
  static const Color roxo = Color(0xFF9333EA);
  static const Color rosa = Color(0xFFEC4899);
  static const Color ciano = Color(0xFF0EA5E9);
  static const Color ambar = Color(0xFFF59E0B);

  /// Cor associada ao perfil selecionado ('Responsável' ou 'Motorista').
  static Color porPerfil(String perfil) =>
      perfil == 'Responsável' ? azulPrincipal : laranjaMotorista;

  /// Paleta usada para distinguir visualmente os cards de cada filho.
  /// Mantida apenas em tons de azul e laranja (cores padrão do app).
  static const List<Color> paletaFilhos = [
    azulPrincipal,
    laranjaMotorista,
    azulClaro,
    laranjaClaro,
    azulEscuro,
    laranjaEscuro,
  ];

  static Color corFilho(int index) => paletaFilhos[index % paletaFilhos.length];

  // ===== Tokens de tema (reagem a Claro/Escuro) =====
  // Usados no lugar de hex fixos (Colors.white, Color(0xFFF8FAFC),
  // Colors.black87, Colors.grey.shade600...) espalhados pelas telas, pra que
  // o modo escuro realmente mude a aparência do app em vez de só trocar o
  // ThemeMode por baixo dos panos sem efeito visual nenhum.

  /// Fundo de Scaffold.
  static Color fundo(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  /// Fundo de card/container "de superfície" (era Colors.white fixo).
  static Color superficie(BuildContext context) => Theme.of(context).cardColor;

  /// Borda neutra de card (era Colors.grey.shade200/shade100 fixo).
  static Color borda(BuildContext context) => Theme.of(context).dividerColor;

  /// Texto principal / título (era Colors.black87, Colors.black, 0xFF1E293B fixo).
  static Color textoPrincipal(BuildContext context) => Theme.of(context).colorScheme.onSurface;

  /// Texto secundário / legenda (era Colors.grey.shade600, grey[500] fixo).
  /// No escuro usa um cinza-claro (referência Discord/Chrome) — bem mais
  /// claro que o cinza do modo claro, senão fica ilegível sobre fundo escuro.
  static Color textoSecundario(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9AA0A6) : Colors.grey.shade600;

  /// Para cor de acento usada como ÍCONE dentro de um badge com fundo
  /// `cor.withValues(alpha: ~0.1-0.16)` (ex.: `_linhaConfig`, `SecaoCardWrapper`,
  /// `CardFilho`). Os tons mais escuros da paleta (`azulEscuro`,
  /// `laranjaEscuro`) ficam quase invisíveis nesse badge quando a superfície
  /// ao redor também é escura — no tema escuro, troca pela variante clara da
  /// mesma família; nos demais casos devolve a cor original sem alteração.
  static Color corIconeLegivel(BuildContext context, Color cor) {
    if (Theme.of(context).brightness != Brightness.dark) return cor;
    if (cor == azulEscuro) return azulClaro;
    if (cor == laranjaEscuro) return laranjaClaro;
    return cor;
  }
}
