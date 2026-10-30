import 'package:cloud_firestore/cloud_firestore.dart';

/// Posição GPS ao vivo do motorista enquanto ele está com uma corrida
/// iniciada — ver usuarios/{motoristaUid}/localizacao_ativa/atual.
class LocalizacaoMotorista {
  final double lat;
  final double lng;
  final bool emRota;
  final DateTime? atualizadoEm;

  const LocalizacaoMotorista({
    required this.lat,
    required this.lng,
    required this.emRota,
    required this.atualizadoEm,
  });

  factory LocalizacaoMotorista.fromMap(Map<String, dynamic> map) {
    return LocalizacaoMotorista(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      emRota: map['emRota'] as bool? ?? false,
      atualizadoEm: (map['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }
}
