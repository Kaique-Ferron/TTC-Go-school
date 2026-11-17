import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clima.dart';

// API de clima (Open-Meteo) — gratuita, sem chave.
class ClimaService {
  ClimaService._();
  static final ClimaService instance = ClimaService._();

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Clima?> buscarClimaAtual({required double lat, required double lng}) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'current_weather': 'true',
      });
      final resposta = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) return null;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final atual = dados['current_weather'] as Map<String, dynamic>?;
      if (atual == null) return null;

      return Clima.fromMap(atual);
    } catch (_) {
      return null;
    }
  }
}
