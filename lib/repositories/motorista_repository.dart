import '../models/motorista_model.dart';

/// Fonte de dados dos motoristas exibidos na aba "Serviços" da landpage.
/// Mockado por enquanto — isolar aqui facilita trocar por uma consulta
/// real ao Firestore no futuro, sem tocar na UI.
class MotoristaRepository {
  static List<Motorista> obterMotoristas() {
    return const [
      Motorista(nome: 'Carlos Silva', corridas: '1.240', tempo: '3 anos', crm: '48392-SP', fotoPerfil: ''),
      Motorista(nome: 'Mariana Souza', corridas: '890', tempo: '1 ano', crm: '19455-SP', fotoPerfil: ''),
      Motorista(nome: 'Roberto Alves', corridas: '3.450', tempo: '5 anos', crm: '99321-SP', fotoPerfil: ''),
      Motorista(nome: 'Leticia Lopes', corridas: '1.234', tempo: '12 anos', crm: '95321-SP', fotoPerfil: ''),
      Motorista(nome: 'Felipe Alcantra', corridas: '2.240', tempo: '1 ano', crm: '95421-SP', fotoPerfil: ''),
    ];
  }
}
