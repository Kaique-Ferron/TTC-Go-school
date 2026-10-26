import 'package:latlong2/latlong.dart';

/// Um ponto de parada na rota do Motorista: a casa de um responsável (pode
/// ter mais de um filho dele na mesma van/período, por isso [filhosNomes]
/// é uma lista) — montado a partir das contratações ativas desse motorista,
/// uma por período (Manhã/Tarde).
class ParadaMotorista {
  final String responsavelUid;
  final String responsavelNome;
  final String endereco;
  final double? lat;
  final double? lng;
  final List<String> filhosNomes;
  final String periodo;

  const ParadaMotorista({
    required this.responsavelUid,
    required this.responsavelNome,
    required this.endereco,
    required this.lat,
    required this.lng,
    required this.filhosNomes,
    required this.periodo,
  });

  bool get temLocalizacao => lat != null && lng != null;

  LatLng get posicao => LatLng(lat!, lng!);
}
