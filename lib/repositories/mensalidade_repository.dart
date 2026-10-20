import '../models/mensalidade_model.dart';

/// Dados de exemplo (mock) usados para semear `usuarios/{uid}/mensalidades`
/// no Firestore — ver FirestoreService.semearMensalidadesMock e
/// firestore/MIGRATIONS.md. A tela de Finanças lê do Firestore de verdade;
/// isso aqui só alimenta o botão "Carregar dados de exemplo".
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
