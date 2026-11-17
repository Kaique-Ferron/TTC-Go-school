
class NotificacoesConfig {
  static const String appId = 'c28e1d00-4d1a-4072-8eb5-b3bcfba4aff6';
  static const String restApiKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY');

  static bool get temChave => restApiKey.isNotEmpty;
}
