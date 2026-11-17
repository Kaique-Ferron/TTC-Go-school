import 'config/notificacoes_config.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    try {
      await NotificationService.initOneSignal(NotificacoesConfig.appId);
    } catch (e) {
      debugPrint('Não foi possível inicializar o OneSignal: $e');
    }
  }

  runApp(const GoSchoolApp());
}
