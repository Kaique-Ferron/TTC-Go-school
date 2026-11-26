import 'package:latlong2/latlong.dart';
import 'escola_rota.dart';

class ParadaMotorista {
  final String responsavelUid;
  final String responsavelNome;
  final String endereco;
  final double? lat;
  final double? lng;
  final List<String> filhosNomes;
  final String periodo;

  final List<EscolaRota> escolas;

  const ParadaMotorista({
    required this.responsavelUid,
    required this.responsavelNome,
    required this.endereco,
    required this.lat,
    required this.lng,
    required this.filhosNomes,
    required this.periodo,
    this.escolas = const [],
  });

  bool get temLocalizacao => lat != null && lng != null;

  LatLng get posicao => LatLng(lat!, lng!);
}
