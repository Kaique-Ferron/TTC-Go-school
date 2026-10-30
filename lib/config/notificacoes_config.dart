/// Configuração de notificações push (OneSignal).
///
/// O App ID não é segredo (fica no app de qualquer forma, é só um
/// identificador). A REST API Key É segredo de verdade — com ela dá pra
/// mandar notificação pra qualquer usuário. O app não tem servidor próprio
/// (Cloud Functions exigiria o plano Blaze/cartão, que este projeto não
/// usa), então o próprio app Flutter chama a API do OneSignal direto.
/// Ciente da troca: a REST API Key fica embutida no app (decisão tomada
/// com o usuário) — mesmo padrão usado pra outras chaves sensíveis deste
/// projeto: não fica escrita aqui, só passada via --dart-define (ver
/// run_dev.ps1, gitignorado):
///
///   flutter run -d chrome --dart-define=ONESIGNAL_REST_API_KEY=SUA_KEY_AQUI
///
/// Sem o --dart-define, NotificationService.enviarPush simplesmente não
/// manda nada (não trava o envio de mensagem).
class NotificacoesConfig {
  static const String appId = 'c28e1d00-4d1a-4072-8eb5-b3bcfba4aff6';
  static const String restApiKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY');

  static bool get temChave => restApiKey.isNotEmpty;
}
