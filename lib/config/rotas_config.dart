/// Configuração do provedor de otimização de rotas (OpenRouteService) —
/// usado por RotaService pra calcular a melhor ordem de embarque das
/// crianças e o trajeto real até a escola.
///
/// Mesmo padrão de lib/config/mapa_config.dart: a key NÃO fica escrita
/// aqui (GitHub bloqueia push com chave de API detectável, e é uma
/// credencial de verdade — diferente das keys do Firebase, essa dá acesso
/// a uma cota paga-por-uso). Ela é passada na hora de rodar/buildar via
/// --dart-define, veja run_dev.ps1/run_dev.sh (gitignorados, não comitados).
///
///   flutter run -d chrome --dart-define=ORS_API_KEY=SUA_KEY_AQUI
///
/// Sem o --dart-define, RotaService não calcula o trajeto e os widgets
/// que dependem dele devem tratar `temChave == false` (não travar o app).
class RotasConfig {
  static const String orsApiKey = String.fromEnvironment('ORS_API_KEY');

  static bool get temChave => orsApiKey.isNotEmpty;
}
