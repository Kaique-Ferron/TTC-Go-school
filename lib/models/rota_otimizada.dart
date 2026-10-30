import 'package:latlong2/latlong.dart';
import 'parada_rota.dart';

/// Resultado do cálculo de rota: ordem otimizada das paradas (casas das
/// crianças, na melhor sequência de embarque — sempre calculada local,
/// sem API) + geometria pra desenhar no mapa + duração/distância totais.
///
/// [trajetoReal] diz se [geometria] veio da API de ruas de verdade
/// (OpenRouteService, quando configurada e disponível) ou é só uma
/// estimativa em linha reta entre os pontos (fallback sem chave/sem
/// internet) — a UI usa isso pra decidir se mostra o aviso de estimativa.
class RotaOtimizada {
  final List<ParadaRota> ordemParadas;
  final List<LatLng> geometria;
  final Duration duracao;
  final double distanciaKm;
  final bool trajetoReal;

  const RotaOtimizada({
    required this.ordemParadas,
    required this.geometria,
    required this.duracao,
    required this.distanciaKm,
    this.trajetoReal = false,
  });
}
