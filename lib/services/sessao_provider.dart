import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class SessaoProvider extends ChangeNotifier {
  SessaoProvider() {
    _assinatura = AuthService.instance.logado.listen((_) => notifyListeners());
  }

  late final StreamSubscription<bool> _assinatura;

  bool get logado => AuthService.instance.uidAtual != null;
  String? get uid => AuthService.instance.uidAtual;
  String? get email => AuthService.instance.emailAtual;

  String get uidEfetivo => uid ?? 'usuario-teste';

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }
}
