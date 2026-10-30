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
  // Escola de destino das crianças dessa parada (gravado uma vez, no
  // momento da contratação — ver registrarContratacao). Pode vir vazio em
  // contratações feitas antes dessa funcionalidade existir, ou se o
  // responsável nunca marcou a localização da escola no cadastro do filho.
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
