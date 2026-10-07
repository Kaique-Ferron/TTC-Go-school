import '../models/mensalidade_model.dart';

/// Fonte de dados das mensalidades exibidas na tela de Finanças do
/// Motorista. Mockado por enquanto — isolar aqui facilita trocar por uma
/// consulta real ao Firestore no futuro, sem tocar na UI.
class MensalidadeRepository {
  static List<Mensalidade> obterMensalidades() {
    final hoje = DateTime.now();
    return [
      Mensalidade(
        responsavelNome: 'Marcos Silva',
        filhoNome: 'João Silva',
        valor: 320.0,
        data: DateTime(hoje.year, hoje.month, 5),
        status: 'Pago',
      ),
      Mensalidade(
        responsavelNome: 'Ana Pereira',
        filhoNome: 'Beatriz Pereira',
        valor: 300.0,
        data: DateTime(hoje.year, hoje.month, 5),
        status: 'Pago',
      ),
      Mensalidade(
        responsavelNome: 'Carlos Souza',
        filhoNome: 'Miguel Souza',
        valor: 340.0,
        data: DateTime(hoje.year, hoje.month, 8),
        status: 'Pago',
      ),
      Mensalidade(
        responsavelNome: 'Patrícia Lima',
        filhoNome: 'Lucas Lima',
        valor: 300.0,
        data: DateTime(hoje.year, hoje.month, 10),
        status: 'Pendente',
      ),
      Mensalidade(
        responsavelNome: 'Rafael Costa',
        filhoNome: 'Sophia Costa',
        valor: 320.0,
        data: DateTime(hoje.year, hoje.month, 10),
        status: 'Pendente',
      ),
    ];
  }
}
