import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_provider.dart';
import '../services/preferencias_provider.dart';
import '../theme/cores.dart';
import '../telas/auth/selecao_perfil/selecao_perfil.dart';
import '../telas/auth/cadastro/cadastro.dart';
import '../telas/auth/recuperar_senha/recuperar_senha.dart';
import '../telas/landpage/tela_inicio_responsavel.dart';
import '../telas/meu_perfil/tela_perfil.dart';
import '../telas/meus_filhos/meus_filhos.dart';
import '../telas/configuracoes/configuracoes_tela.dart'; // <--- Import corrigido com ../
import 'auth_gate.dart';
import '../telas/procurar_motorista/procurar_motorista_tela.dart';
import '../telas/chat/tela_conversas.dart';



import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class GoSchoolApp extends StatelessWidget {
  const GoSchoolApp({super.key});

  /// Tema claro/escuro com os mesmos tokens usados em [AppCores] (fundo,
  /// superfície/card, borda, texto principal/secundário) — garante que
  /// widgets Material "crus" (sem cor explícita) e os helpers de AppCores
  /// fiquem sempre consistentes entre si, nos dois temas.
  static ThemeData _construirTema(Brightness brilho) {
    final escuro = brilho == Brightness.dark;

    // Paleta escura inspirada em Discord/Windows 11: fundo grafite neutro
    // (nunca preto puro), superfície de card um ou dois tons mais clara
    // (elevação por luminosidade, já que sombra quase não aparece no
    // escuro), e AppBar/Drawer "flat" (mesma cor do fundo, sem se destacar
    // como um card) — ao contrário do claro, onde a AppBar branca já
    // contrasta com o fundo F8FAFC.
    final corFundo = escuro ? const Color(0xFF18191C) : const Color(0xFFF8FAFC);
    final corSuperficie = escuro ? const Color(0xFF222427) : Colors.white;
    final corAppBar = escuro ? corFundo : Colors.white;
    final corBorda = escuro ? Colors.white.withValues(alpha: 0.10) : Colors.grey.shade200;

    // Texto: branco suavizado (não 0xFFFFFFFF puro, cansa a vista — mesma
    // referência do Chrome/Windows) e cinza-claro pro secundário (Discord/
    // Chrome), bem mais claro que o cinza usado no modo claro.
    final corTextoPrincipal = escuro ? const Color(0xFFE8EAED) : const Color(0xFF1E293B);
    final corTextoSecundario = escuro ? const Color(0xFF9AA0A6) : Colors.grey.shade600;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppCores.azulPrincipal,
      brightness: brilho,
      surface: corSuperficie,
      onSurface: corTextoPrincipal,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: corFundo,
      cardColor: corSuperficie,
      dividerColor: corBorda,
      textTheme: ThemeData(brightness: brilho).textTheme.apply(
            bodyColor: corTextoPrincipal,
            displayColor: corTextoPrincipal,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: corAppBar,
        foregroundColor: corTextoPrincipal,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: corSuperficie,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: corSuperficie,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: corAppBar,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: corAppBar,
      ),
      iconTheme: IconThemeData(color: corTextoSecundario),
      hintColor: corTextoSecundario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessaoProvider()),
        ChangeNotifierProvider(create: (_) => PreferenciasProvider()),
      ],
      child: Consumer<PreferenciasProvider>(
        builder: (context, prefs, _) {
          return MaterialApp(
            title: 'GoSchool',
            debugShowCheckedModeBanner: false,
            themeMode: prefs.themeMode,
            theme: _construirTema(Brightness.light),
            darkTheme: _construirTema(Brightness.dark),
            // Builder aplica duas coisas no app inteiro, sem precisar
            // mexer em cada tela: (1) a escala de fonte escolhida em
            // Configurações; (2) na Web, a cara de celular (mesma largura
            // do cartão de login) centralizado na janela do navegador.
            builder: (context, child) {
              Widget resultado = MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(prefs.escalaFonte)),
                child: child!,
              );

              if (kIsWeb) {
                resultado = ColoredBox(
                  color: const Color(0xFFE2E6ED),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: resultado,
                    ),
                  ),
                );
              }

              return resultado;
            },
            home: const AuthGate(),
            routes: {
              '/selecao-perfil': (context) => const TelaSelecaoPerfil(),
              '/cadastro': (context) => const TelaCadastro(),
              '/recuperar-senha': (context) => const TelaRecuperarSenha(),
              '/inicio': (context) => const TelaInicioResponsavel(),
              '/meu-perfil': (context) => const TelaPerfil(),
              '/meus-filhos': (context) => const MeusFilhosTela(),
              '/configuracoes': (context) => const ConfiguracoesTela(),
              '/procurar-motorista': (context) => const ProcurarMotoristaTela(),
              '/chat': (context) => const TelaConversas(),
            },
          );
        },
      ),
    );
  }
}