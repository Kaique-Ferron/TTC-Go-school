import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// API de rotas (OSRM)
class RotaRealService {
  RotaRealService._();
  static final RotaRealService instance = RotaRealService._();

  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<(List<LatLng>, double)?> calcularCaminho(List<LatLng> pontos) async {
    if (pontos.length < 2) return null;

    try {
      final coordenadas = pontos.map((p) => '${p.longitude},${p.latitude}').join(';');
      final uri = Uri.parse('$_baseUrl/$coordenadas').replace(queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      });

      final resposta = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resposta.statusCode != 200) return null;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      if (dados['code'] != 'Ok') return null;

      final rotas = dados['routes'] as List?;
      if (rotas == null || rotas.isEmpty) return null;
      final rota = rotas.first as Map<String, dynamic>;

      final coordenadasGeometria = (rota['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      final distanciaKm = (rota['distance'] as num).toDouble() / 1000;

      return (coordenadasGeometria, distanciaKm);
    } catch (_) {
      return null;
    }
  }
}
