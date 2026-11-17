import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  final String id;
  final List<String> participantes;
  final Map<String, String> participantesNomes;
  final String ultimaMensagem;
  final DateTime? ultimaMensagemEm;

  const Conversa({
    required this.id,
    required this.participantes,
    required this.participantesNomes,
    required this.ultimaMensagem,
    required this.ultimaMensagemEm,
  });

  String outroUid(String meuUid) =>
      participantes.firstWhere((uid) => uid != meuUid, orElse: () => '');

  String outroNome(String meuUid) => participantesNomes[outroUid(meuUid)] ?? 'Usuário';

  factory Conversa.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['ultimaMensagemEm'];
    return Conversa(
      id: id,
      participantes: List<String>.from(map['participantes'] ?? const []),
      participantesNomes: Map<String, String>.from(map['participantesNomes'] ?? const {}),
      ultimaMensagem: map['ultimaMensagem'] ?? '',
      ultimaMensagemEm: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
