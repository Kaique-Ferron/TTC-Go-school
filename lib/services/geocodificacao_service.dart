import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// API de geocodificação (Nominatim)
class GeocodificacaoService {
  GeocodificacaoService._();
  static final GeocodificacaoService instance = GeocodificacaoService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  // Guarda o resultado (inclusive "não encontrado") pelo texto exato do
  // endereço já consultado nessa sessão — evita repetir a mesma busca de
  // rede quando a mesma tela recarrega. Não entra em cache quando a chamada
  // falha (timeout, sem rede): isso pode ter sido só uma instabilidade.
  final Map<String, LatLng?> _cache = {};

  Future<LatLng?> geocodificar(String enderecoCompleto) async {
    final chave = enderecoCompleto.trim().toLowerCase();
    if (chave.isEmpty) return null;
    if (_cache.containsKey(chave)) return _cache[chave];

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
      if (resultados.isEmpty) {
        _cache[chave] = null;
        return null;
      }

      final primeiro = resultados.first as Map<String, dynamic>;
      final lat = double.tryParse(primeiro['lat'] as String? ?? '');
      final lng = double.tryParse(primeiro['lon'] as String? ?? '');
      if (lat == null || lng == null) {
        _cache[chave] = null;
        return null;
      }

      final resultado = LatLng(lat, lng);
      _cache[chave] = resultado;
      return resultado;
    } catch (_) {
      return null;
    }
  }
}
