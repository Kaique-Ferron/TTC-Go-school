import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Busca o trajeto real nas ruas (geometria + distância) passando pelos
/// pontos dados, na ordem dada, usando o servidor público de demonstração
/// do OSRM (Open Source Routing Machine) — gratuito, sem chave, mantido
/// pela comunidade OpenStreetMap. Diferente do OpenRouteService (que
/// exige uma key pessoal), esse não precisa de nenhum cadastro.
///
/// Antes disso, o app buscava os dados crus das ruas (Overpass) e
/// calculava o caminho com Dijkstra aqui dentro — mas o Overpass público
/// é feito pra consulta de dados do mapa, não pra roteamento em tempo
/// real, e ficava sobrecarregado com frequência (às vezes devolvendo
/// zero ruas pra qualquer lugar), caindo pra linha reta demais. O OSRM já
/// É um motor de rotas de verdade, então é muito mais rápido e confiável
/// pra essa tarefa — o preço é não ser mais "100% calculado por nós":
/// quem desenha o trajeto nas ruas agora é o OSRM, não o nosso Dijkstra.
class RotaRealService {
  RotaRealService._();
  static final RotaRealService instance = RotaRealService._();

  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Retorna a geometria real nas ruas passando pelos [pontos] (na ordem
  /// dada — o OSRM não reordena nada, só liga os pontos nessa sequência)
  /// e a distância total em km. Retorna null em qualquer falha (sem
  /// internet, serviço fora do ar, sem rota possível entre os pontos) —
  /// quem chamou cai de volta pro traçado em linha reta nesse caso.
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
