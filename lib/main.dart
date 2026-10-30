import 'config/notificacoes_config.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Adicionado
import 'app/app.dart';
import 'firebase_options.dart'; // Adicionado

void main() async {
  // Garante que o Flutter inicialize os recursos nativos antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as configurações geradas pelo FlutterFire
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // OneSignal não tem suporte no Flutter Web (precisaria do SDK JS no
  // web/index.html, que este projeto não tem) — nem tenta inicializar lá.
  // `OneSignal.initialize()` dispara uma chamada de plugin não-awaited
  // internamente; na Web ela rejeita fora da cadeia do try/catch (aparece
  // como "DartError" solto no console), então pular a chamada inteira é
  // mais limpo do que só capturar a exceção. No mobile inicializa normal.
  if (!kIsWeb) {
    try {
      await NotificationService.initOneSignal(NotificacoesConfig.appId);
    } catch (e) {
      debugPrint('Não foi possível inicializar o OneSignal: $e');
    }
  }

  runApp(const GoSchoolApp());
}
