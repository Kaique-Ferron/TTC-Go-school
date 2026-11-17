import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/notificacoes_config.dart';

// API de notificações (OneSignal)
class NotificationService {
  static String? _uidSincronizado;

  static String? get subscriptionIdAtual {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (_) {
      return null;
    }
  }

  static Future<void> initOneSignal(String appId) async {
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  static void sincronizarInscricao(String? uid) {
    if (uid == null) {
      _uidSincronizado = null;
      return;
    }
    if (uid == _uidSincronizado) return;

    final subscriptionId = subscriptionIdAtual;
    if (subscriptionId == null || subscriptionId.isEmpty) return;

    _uidSincronizado = uid;
    _salvarSubscriptionId(uid, subscriptionId);
  }

  static Future<void> _salvarSubscriptionId(String usuarioId, String subscriptionId) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(usuarioId).update({
        'onesignal_player_id': subscriptionId,
      });
    } catch (_) {

    }
  }

  static Future<void> enviarPush({
    required String subscriptionId,
    required String titulo,
    required String mensagem,
  }) async {
    if (!NotificacoesConfig.temChave || subscriptionId.isEmpty) return;

    try {
      await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Authorization': 'Basic ${NotificacoesConfig.restApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': NotificacoesConfig.appId,
          'include_subscription_ids': [subscriptionId],
          'headings': {'en': titulo},
          'contents': {'en': mensagem},
        }),
      );
    } catch (_) {

    }
  }
}
