import 'package:cloud_firestore/cloud_firestore.dart';

/// Uma mensagem dentro de uma conversa entre Responsável e Motorista.
/// Caminho: conversas/{conversaId}/mensagens/{mensagemId}.
class Mensagem {
  final String id;
  final String remetenteUid;
  final String texto;
  final DateTime enviadaEm;

  const Mensagem({
    required this.id,
    required this.remetenteUid,
    required this.texto,
    required this.enviadaEm,
  });

  bool enviadaPor(String uid) => remetenteUid == uid;

  Map<String, dynamic> toMap() {
    return {
      'remetenteUid': remetenteUid,
      'texto': texto,
      'enviadaEm': FieldValue.serverTimestamp(),
    };
  }

  factory Mensagem.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['enviadaEm'];
    return Mensagem(
      id: id,
      remetenteUid: map['remetenteUid'] ?? '',
      texto: map['texto'] ?? '',
      enviadaEm: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }
}
