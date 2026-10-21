import 'package:cloud_firestore/cloud_firestore.dart';

/// Uma avaliação que um Responsável deixa pra um Motorista — nota de 1 a 5
/// com comentário opcional. Caminho: usuarios/{motoristaUid}/avaliacoes/{responsavelUid}
/// (um documento por responsável, pra cada um só poder avaliar uma vez e
/// poder atualizar a própria nota depois).
class Avaliacao {
  final String responsavelUid;
  final String responsavelNome;
  final int nota;
  final String comentario;
  final DateTime criadoEm;

  const Avaliacao({
    required this.responsavelUid,
    required this.responsavelNome,
    required this.nota,
    required this.comentario,
    required this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'responsavelUid': responsavelUid,
      'responsavelNome': responsavelNome,
      'nota': nota,
      'comentario': comentario,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }

  factory Avaliacao.fromMap(Map<String, dynamic> map) {
    final timestamp = map['criadoEm'];
    return Avaliacao(
      responsavelUid: map['responsavelUid'] ?? '',
      responsavelNome: map['responsavelNome'] ?? '',
      nota: (map['nota'] as num?)?.toInt() ?? 0,
      comentario: map['comentario'] ?? '',
      criadoEm: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }
}
