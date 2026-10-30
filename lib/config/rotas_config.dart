/// Configuração da API de rotas de ruas reais (OpenRouteService) — usada
/// só pra desenhar o traçado real nas ruas; a ORDEM das paradas continua
/// calculada 100% local em RotaService (caixeiro-viajante, sem API), já
/// que isso não precisa de mapa de ruas, só de distância entre pontos.
///
/// Sem a chave configurada (ou se a chamada falhar), RotaService cai de
/// volta pro traçado em linha reta — a ordem das paradas continua certa,
/// só o desenho no mapa fica reto em vez de seguir a rua.
///
/// A key não fica escrita aqui (GitHub bloqueia push com chave detectável,
/// e é uma credencial de verdade — diferente das keys do Firebase, essa dá
/// acesso a uma cota paga-por-uso). Só passada via --dart-define (ver
/// run_dev.ps1, gitignorado):
///
///   flutter run -d chrome --dart-define=ORS_API_KEY=SUA_KEY_AQUI
class RotasConfig {
  static const String orsApiKey = String.fromEnvironment('ORS_API_KEY');

  static bool get temChave => orsApiKey.isNotEmpty;
}
