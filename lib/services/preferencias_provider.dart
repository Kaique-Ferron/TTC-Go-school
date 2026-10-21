import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Preferências de aparência do usuário logado (tema e tamanho da fonte),
/// persistidas em usuarios/{uid} e aplicadas de verdade no MaterialApp
/// (ThemeMode + escala de fonte) — ao contrário dos switches de
/// notificação/privacidade da tela de Configurações, que ainda são só UI.
class PreferenciasProvider extends ChangeNotifier {
  String _tema = 'Automático';
  String _tamanhoFonte = 'Média';
  StreamSubscription<dynamic>? _assinatura;
  String? _uidAssinado;

  String get tema => _tema;
  String get tamanhoFonte => _tamanhoFonte;

  ThemeMode get themeMode {
    switch (_tema) {
      case 'Claro':
        return ThemeMode.light;
      case 'Escuro':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  double get escalaFonte {
    switch (_tamanhoFonte) {
      case 'Pequena':
        return 0.9;
      case 'Grande':
        return 1.2;
      default:
        return 1.0;
    }
  }

  /// Acompanha as preferências do usuário logado em tempo real (reage a
  /// mudanças feitas em outro dispositivo, e volta ao padrão no logout).
  /// Idempotente: chamar de novo com o mesmo uid não recria a assinatura.
  void escutarUsuario(String? uid) {
    if (uid == _uidAssinado) return;
    _uidAssinado = uid;
    _assinatura?.cancel();

    if (uid == null) {
      _tema = 'Automático';
      _tamanhoFonte = 'Média';
      notifyListeners();
      return;
    }

    _assinatura = FirestoreService.instance.usuarioStream(uid).listen((usuario) {
      if (usuario == null) return;
      _tema = usuario.tema;
      _tamanhoFonte = usuario.tamanhoFonte;
      notifyListeners();
    });
  }

  Future<void> salvar({required String tema, required String tamanhoFonte}) async {
    _tema = tema;
    _tamanhoFonte = tamanhoFonte;
    notifyListeners(); // aplica na hora, sem esperar o round-trip do Firestore

    final uid = AuthService.instance.uidAtual;
    if (uid == null) return;
    await FirestoreService.instance.salvarPreferencias(uid, tema: tema, tamanhoFonte: tamanhoFonte);
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }
}
