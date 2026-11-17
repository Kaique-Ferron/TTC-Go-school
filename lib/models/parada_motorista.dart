import 'package:latlong2/latlong.dart';

class ParadaMotorista {
  final String responsavelUid;
  final String responsavelNome;
  final String endereco;
  final double? lat;
  final double? lng;
  final List<String> filhosNomes;
  final String periodo;

  final String escolaNome;
  final double? escolaLat;
  final double? escolaLng;

  const ParadaMotorista({
    required this.responsavelUid,
    required this.responsavelNome,
    required this.endereco,
    required this.lat,
    required this.lng,
    required this.filhosNomes,
    required this.periodo,
    this.escolaNome = '',
    this.escolaLat,
    this.escolaLng,
  });

  bool get temLocalizacao => lat != null && lng != null;
  bool get temLocalizacaoEscola => escolaLat != null && escolaLng != null;

  LatLng get posicao => LatLng(lat!, lng!);
  LatLng get posicaoEscola => LatLng(escolaLat!, escolaLng!);
}
