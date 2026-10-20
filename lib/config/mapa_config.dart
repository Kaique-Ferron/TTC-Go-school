/// Configuração central do provedor de mapa (Mapbox) — usado em
/// lib/telas/landpage/logica-landpage.dart e lib/telas/meu_perfil/mapa_casa_tela.dart.
///
/// O token NÃO fica mais escrito aqui — o GitHub bloqueia qualquer push que
/// contenha um token no formato do Mapbox (mesmo sendo o token público "pk.",
/// feito pra ficar no código do cliente). Em vez disso, o token é passado na
/// hora de rodar/buildar o app, via --dart-define:
///
///   flutter run -d chrome --dart-define=MAPBOX_ACCESS_TOKEN=pk.SEU_TOKEN_AQUI
///
/// Sem o --dart-define, o mapa cai de volta pro provedor gratuito do
/// Wikimedia (sem chave) — nada quebra, só fica com o visual mais simples.
class MapaConfig {
  static const String mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static bool get temMapbox => mapboxAccessToken.isNotEmpty;

  static const String _mapboxTileUrlTemplate =
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken';

  static const String _wikimediaTileUrlTemplate = 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png';

  static String get tileUrlTemplate => temMapbox ? _mapboxTileUrlTemplate : _wikimediaTileUrlTemplate;
}
