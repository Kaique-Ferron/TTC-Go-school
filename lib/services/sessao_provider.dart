import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Estado de sessão do usuário, compartilhado entre telas via Provider.
/// Evita que cada tela precise chamar `AuthService.instance` diretamente
/// só para saber se há um usuário logado.
class SessaoProvider extends ChangeNotifier {
  SessaoProvider() {
    _assinatura = AuthService.instance.logado.listen((_) => notifyListeners());
  }

  late final StreamSubscription<bool> _assinatura;

  bool get logado => AuthService.instance.uidAtual != null;
  String? get uid => AuthService.instance.uidAtual;
  String? get email => AuthService.instance.emailAtual;

  /// Uid real quando há sessão, ou um uid de teste enquanto login/cadastro
  /// estiverem em modo de navegação (sem autenticar de verdade no Firebase).
  String get uidEfetivo => uid ?? 'usuario-teste';

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }
}
