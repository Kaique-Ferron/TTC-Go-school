import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa o pagamento de um responsável ao motorista por um filho,
/// exibido na tela de Finanças do Motorista.
class Mensalidade {
  final String? id;
  final String responsavelNome;
  final String filhoNome;
  final double valor;
  final DateTime data;
  final String status; // 'Pago' ou 'Pendente'

  const Mensalidade({
    this.id,
    required this.responsavelNome,
    required this.filhoNome,
    required this.valor,
    required this.data,
    required this.status,
  });

  bool get pago => status == 'Pago';

  Map<String, dynamic> toMap() {
    return {
      'responsavelNome': responsavelNome,
      'filhoNome': filhoNome,
      'valor': valor,
      'data': Timestamp.fromDate(data),
      'status': status,
    };
  }

  factory Mensalidade.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['data'];
    return Mensalidade(
      id: id,
      responsavelNome: map['responsavelNome'] ?? '',
      filhoNome: map['filhoNome'] ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      data: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: map['status'] ?? 'Pendente',
    );
  }
}
