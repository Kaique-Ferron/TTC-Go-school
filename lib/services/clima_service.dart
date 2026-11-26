import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clima.dart';

// API de clima (Open-Meteo) — gratuita, sem chave.
class ClimaService {
  ClimaService._();
  static final ClimaService instance = ClimaService._();

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _validadeCache = Duration(minutes: 15);

  final Map<String, (Clima, DateTime)> _cache = {};

  // Arredonda pra ~1km — clima não muda nessa escala, e evita buscar de novo
  // só porque o GPS andou alguns metros (ex.: durante uma corrida ativa).
  String _chaveCache(double lat, double lng) => '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';

  Future<Clima?> buscarClimaAtual({required double lat, required double lng}) async {
    final chave = _chaveCache(lat, lng);
    final emCache = _cache[chave];
    if (emCache != null && DateTime.now().difference(emCache.$2) < _validadeCache) {
      return emCache.$1;
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'current_weather': 'true',
      });
      final resposta = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) return emCache?.$1;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final atual = dados['current_weather'] as Map<String, dynamic>?;
      if (atual == null) return emCache?.$1;

      final clima = Clima.fromMap(atual);
      _cache[chave] = (clima, DateTime.now());
      return clima;
    } catch (_) {
      // Rede falhou agora — devolve o último clima válido que tinha pra essa
      // região, em vez de deixar o card em branco.
      return emCache?.$1;
    }
  }
}
