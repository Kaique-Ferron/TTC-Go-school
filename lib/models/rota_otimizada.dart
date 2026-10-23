import 'package:latlong2/latlong.dart';
import 'parada_rota.dart';

/// Resultado do cálculo de rota: ordem otimizada das paradas (casas das
/// crianças, na melhor sequência de embarque) + geometria real nas ruas
/// (pra desenhar no mapa) + duração/distância totais, vindos do
/// OpenRouteService.
class RotaOtimizada {
  final List<ParadaRota> ordemParadas;
  final List<LatLng> geometria;
  final Duration duracao;
  final double distanciaKm;

  const RotaOtimizada({
    required this.ordemParadas,
    required this.geometria,
    required this.duracao,
    required this.distanciaKm,
  });
}
