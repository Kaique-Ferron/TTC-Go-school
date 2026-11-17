// API do mapa (tiles)
class MapaConfig {
  static const String mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static bool get temMapbox => mapboxAccessToken.isNotEmpty;

  static const String _mapboxTileUrlTemplate =
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken';

  static const String _wikimediaTileUrlTemplate = 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png';

  static String get tileUrlTemplate => temMapbox ? _mapboxTileUrlTemplate : _wikimediaTileUrlTemplate;
}
