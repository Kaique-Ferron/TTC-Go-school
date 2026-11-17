import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

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

  void escutarUsuario(String? uid) {
    if (uid == _uidAssinado) return;
    final uidAnterior = _uidAssinado;
    _uidAssinado = uid;
    _assinatura?.cancel();

    if (uid == null) {
      if (uidAnterior == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {

        if (_uidAssinado != null) return;
        _tema = 'Automático';
        _tamanhoFonte = 'Média';
        notifyListeners();
      });
      return;
    }

    _assinatura = FirestoreService.instance.usuarioStream(uid).listen((
      usuario,
    ) {
      if (usuario == null) return;
      _tema = usuario.tema;
      _tamanhoFonte = usuario.tamanhoFonte;
      notifyListeners();
    });
  }

  Future<void> salvar({
    required String tema,
    required String tamanhoFonte,
  }) async {
    _tema = tema;
    _tamanhoFonte = tamanhoFonte;
    notifyListeners();

    try {
      final uid = AuthService.instance.uidAtual;
      if (uid == null) return;
      await FirestoreService.instance.salvarPreferencias(
        uid,
        tema: tema,
        tamanhoFonte: tamanhoFonte,
      );
    } catch (_) {

    }
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }
}
