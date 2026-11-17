import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConectividadeProvider extends ChangeNotifier {
  bool _online = true;
  StreamSubscription<List<ConnectivityResult>>? _assinatura;

  bool get online => _online;

  ConectividadeProvider() {
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      final resultadoInicial = await Connectivity().checkConnectivity();
      _atualizar(resultadoInicial);
    } catch (_) {

    }

    _assinatura = Connectivity().onConnectivityChanged.listen(_atualizar);
  }

  void _atualizar(List<ConnectivityResult> resultados) {
    final novoOnline = resultados.any((r) => r != ConnectivityResult.none);
    if (novoOnline == _online) return;
    _online = novoOnline;
    notifyListeners();
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }
}
