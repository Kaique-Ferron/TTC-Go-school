import 'package:latlong2/latlong.dart';
import 'parada_rota.dart';

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
