import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// API de geocodificação (Nominatim)
class GeocodificacaoService {
  GeocodificacaoService._();
  static final GeocodificacaoService instance = GeocodificacaoService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<LatLng?> geocodificar(String enderecoCompleto) async {
    if (enderecoCompleto.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': enderecoCompleto,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'br',
      });
      final resposta = await http
          .get(uri, headers: {'User-Agent': 'GoSchoolApp/1.0'})
          .timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) return null;

      final resultados = jsonDecode(resposta.body) as List;
      if (resultados.isEmpty) return null;

      final primeiro = resultados.first as Map<String, dynamic>;
      final lat = double.tryParse(primeiro['lat'] as String? ?? '');
      final lng = double.tryParse(primeiro['lon'] as String? ?? '');
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }
}
