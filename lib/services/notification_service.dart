import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/notificacoes_config.dart';

class NotificationService {
  static String? _uidSincronizado;

  /// Id de inscrição push do dispositivo atual, se o OneSignal já estiver
  /// pronto (null na Web, onde o OneSignal não é inicializado).
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

  /// Salva o id de inscrição push (OneSignal) do usuário logado quando ele
  /// muda — idempotente, mesmo padrão de
  /// PreferenciasProvider.escutarUsuario, já que AuthGate chama isso a cada
  /// rebuild e não queremos regravar o Firestore toda hora. Se o id ainda
  /// não estiver pronto (pode demorar um instante depois do login), não
  /// marca como sincronizado — tenta de novo no próximo rebuild.
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
      // Sem conexão, ou doc ainda não existe nesse instante — não é crítico.
    }
  }

  /// Manda uma notificação push de verdade pro subscriptionId informado,
  /// chamando a API REST do OneSignal direto do app (sem servidor próprio
  /// — ver lib/config/notificacoes_config.dart sobre essa decisão). Nunca
  /// lança exceção: notificação é um extra, não deve travar quem a disparou
  /// (ex.: o envio de uma mensagem de chat).
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
      // Ver comentário acima.
    }
  }
}
