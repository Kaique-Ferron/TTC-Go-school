import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Detecta de verdade quando o aparelho fica sem internet (wifi/dados
/// desligados, modo avião, sinal caiu) — não é um "tentei e deu erro",
/// é o próprio sistema operacional avisando. Observado pelo app inteiro
/// (ver GoSchoolApp) pra mostrar um aviso fixo sempre que isso acontecer,
/// em vez de cada tela falhar silenciosamente ou travar no spinner.
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
      // Sem suporte na plataforma (ex.: algumas configurações de Web) —
      // assume online, não deixa travar o app por causa disso.
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
