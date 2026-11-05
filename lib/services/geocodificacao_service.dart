import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Converte um endereço digitado (rua, número, bairro, CEP) em
/// coordenadas — usa o Nominatim (geocodificação do OpenStreetMap,
/// gratuita e sem chave, mesma família de serviços abertos do
/// RotaRealService e dos tiles do mapa). Diferente do pacote `geocoding`
/// (que não tem implementação nativa pra Web e nunca funciona lá), isso é
/// só uma chamada HTTP comum, então funciona em qualquer plataforma.
///
/// Sem isso, digitar o endereço no cadastro nunca virava uma coordenada —
/// só o pino manual em "Minha Casa" gerava casa_lat/casa_lng, e quem nunca
/// usava aquela tela ficava com a parada "sem localização" pro Motorista
/// pra sempre, mesmo já tendo preenchido o endereço.
class GeocodificacaoService {
  GeocodificacaoService._();
  static final GeocodificacaoService instance = GeocodificacaoService._();

  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Retorna a coordenada aproximada do endereço, ou null se não
  /// conseguir achar (endereço incompleto/errado, sem internet, serviço
  /// fora do ar) — quem chamar deve seguir sem a localização nesse caso,
  /// sem travar cadastro/edição de perfil por isso.
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
