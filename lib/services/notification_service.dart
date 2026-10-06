// Ficheiro: lib/services/notification_service.dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> initOneSignal(String appId) async {
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  static Future<void> salvarSubscriptionId(String usuarioId) async {
    final subscriptionId = OneSignal.User.pushSubscription.id;
    if (subscriptionId != null && subscriptionId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('responsaveis')
          .doc(usuarioId)
          .update({'onesignal_player_id': subscriptionId});
    }
  }
}