/// Representa o pagamento de um responsável ao motorista por um filho,
/// exibido na tela de Finanças do Motorista.
class Mensalidade {
  final String responsavelNome;
  final String filhoNome;
  final double valor;
  final DateTime data;
  final String status; // 'Pago' ou 'Pendente'

  const Mensalidade({
    required this.responsavelNome,
    required this.filhoNome,
    required this.valor,
    required this.data,
    required this.status,
  });

  bool get pago => status == 'Pago';
}
