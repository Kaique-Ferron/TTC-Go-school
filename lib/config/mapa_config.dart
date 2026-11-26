// API do mapa (tiles)
class MapaConfig {
  static const String mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static bool get temMapbox => mapboxAccessToken.isNotEmpty;

  static const String _mapboxTileUrlTemplate =
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken';

  // Wikimedia passou a bloquear uso externo (HTTP 403 — "restricted to
  // Wikimedia and affiliated sites only"), por isso o mapa ficava em branco
  // quando não havia token do Mapbox. OSM oficial é gratuito, sem chave, e
  // aceita uso de apps desde que mande um User-Agent identificando o app.
  static const String _osmTileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String get tileUrlTemplate => temMapbox ? _mapboxTileUrlTemplate : _osmTileUrlTemplate;
}
