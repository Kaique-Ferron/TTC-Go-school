import 'package:latlong2/latlong.dart';

/// Um ponto de parada numa rota a ser otimizada (casa de uma criança) ou
/// o destino final (escola).
class ParadaRota {
  final String id;
  final String label;
  final LatLng posicao;

  const ParadaRota({required this.id, required this.label, required this.posicao});
}
