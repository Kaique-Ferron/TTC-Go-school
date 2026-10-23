import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/rotas_config.dart';
import '../models/parada_rota.dart';
import '../models/rota_otimizada.dart';

/// Calcula a melhor ordem de embarque das crianças e o trajeto real até o
/// destino, usando a API gratuita do OpenRouteService (precisa de uma key
/// pessoal — veja lib/config/rotas_config.dart).
///
/// São dois serviços diferentes do ORS, por isso dois passos:
/// 1) /optimization resolve "em que ordem visitar essas paradas partindo
///    daqui" (problema de roteamento, tipo um caixeiro-viajante).
/// 2) /v2/directions pega essa ordem já definida + o destino final (escola,
///    se houver) e devolve o trajeto real nas ruas: geometria, duração,
///    distância.
class RotaService {
  RotaService._();
  static final RotaService instance = RotaService._();

  static const _baseUrl = 'https://api.openrouteservice.org';

  Future<RotaOtimizada?> calcular({
    required LatLng partida,
    required List<ParadaRota> paradas,
    LatLng? destino,
    String destinoLabel = 'Escola',
  }) async {
    if (!RotasConfig.temChave || paradas.isEmpty) return null;

    final ordem = paradas.length == 1
        ? paradas
        : await _ordemOtima(partida, paradas);
    if (ordem == null) return null;

    final pontos = [
      partida,
      ...ordem.map((p) => p.posicao),
      ?destino,
    ];

    return _tracarRota(pontos, ordem, destino, destinoLabel);
  }

  /// Chama /optimization só pra descobrir a melhor ORDEM das paradas —
  /// a geometria real da rota vem depois, de _tracarRota.
  Future<List<ParadaRota>?> _ordemOtima(
    LatLng partida,
    List<ParadaRota> paradas,
  ) async {
    final corpo = {
      'jobs': [
        for (var i = 0; i < paradas.length; i++)
          {
            'id': i,
            'location': [paradas[i].posicao.longitude, paradas[i].posicao.latitude],
          },
      ],
      'vehicles': [
        {
          'id': 1,
          'profile': 'driving-car',
          'start': [partida.longitude, partida.latitude],
        },
      ],
    };

    try {
      final resposta = await http.post(
        Uri.parse('$_baseUrl/optimization'),
        headers: {
          'Authorization': RotasConfig.orsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(corpo),
      );
      if (resposta.statusCode != 200) return null;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final rotas = dados['routes'] as List?;
      if (rotas == null || rotas.isEmpty) return null;

      final passosDeEmbarque = (rotas.first['steps'] as List)
          .where((passo) => passo['type'] == 'job')
          .toList();

      return passosDeEmbarque
          .map((passo) => paradas[passo['id'] as int])
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Traça o trajeto real nas ruas para a sequência de pontos já definida
  /// (partida -> paradas na ordem otimizada -> destino, se houver).
  Future<RotaOtimizada?> _tracarRota(
    List<LatLng> pontos,
    List<ParadaRota> ordem,
    LatLng? destino,
    String destinoLabel,
  ) async {
    try {
      final resposta = await http.post(
        Uri.parse('$_baseUrl/v2/directions/driving-car/geojson'),
        headers: {
          'Authorization': RotasConfig.orsApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': pontos.map((p) => [p.longitude, p.latitude]).toList(),
        }),
      );
      if (resposta.statusCode != 200) return null;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final features = dados['features'] as List;
      if (features.isEmpty) return null;
      final feature = features.first as Map<String, dynamic>;
      final coordenadas = feature['geometry']['coordinates'] as List;
      final resumo = feature['properties']['summary'] as Map<String, dynamic>;

      return RotaOtimizada(
        ordemParadas: [
          ...ordem,
          if (destino != null)
            ParadaRota(id: 'destino', label: destinoLabel, posicao: destino),
        ],
        geometria: coordenadas
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList(),
        duracao: Duration(seconds: (resumo['duration'] as num).round()),
        distanciaKm: (resumo['distance'] as num) / 1000,
      );
    } catch (_) {
      return null;
    }
  }
}
