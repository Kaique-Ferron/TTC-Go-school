class Motorista {
  final String nome;
  final String corridas;
  final String tempo;
  final String crm;
  final String fotoPerfil;
  final String veiculo; // Novo campo
  final String placa;   // Novo campo

  // Dados mockados (ainda não vêm do Firestore) usados na tela de detalhes
  // que o Responsável vê ao selecionar o motorista.
  final double valorMensalidade;
  final int criancasManha;
  final int criancasTarde;

  const Motorista({
    required this.nome,
    required this.corridas,
    required this.tempo,
    required this.crm,
    required this.fotoPerfil,
    this.veiculo = 'Veículo não informado',
    this.placa = '---',
    this.valorMensalidade = 320.0,
    this.criancasManha = 0,
    this.criancasTarde = 0,
  });

  // Converte os dados vindo do Firestore (Map) para o objeto Motorista
  factory Motorista.fromMap(Map<String, dynamic> map) {
    return Motorista(
      nome: map['nome'] ?? '',
      corridas: map['corridas'] ?? '0',
      tempo: map['tempo'] ?? '0',
      crm: map['crm'] ?? '',
      fotoPerfil: map['fotoPerfil'] ?? '',
      veiculo: map['veiculo'] ?? 'Veículo não informado',
      placa: map['placa'] ?? '---',
    );
  }

  // Converte o objeto Motorista para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'corridas': corridas,
      'tempo': tempo,
      'crm': crm,
      'fotoPerfil': fotoPerfil,
      'veiculo': veiculo,
      'placa': placa,
    };
  }

  /// Converte um documento real de `usuarios` (tipoPerfil: 'motorista') em
  /// Motorista para exibição na aba Serviços — esse documento não tem
  /// 'corridas'/'tempo' (estatísticas que ainda não são rastreadas), então
  /// ficam vazios e a UI esconde essa linha quando não há dado.
  factory Motorista.fromUsuarioMap(Map<String, dynamic> map) {
    final veiculo = (map['veiculo'] as String?) ?? '';
    final placa = (map['placa'] as String?) ?? '';
    final licenca = (map['licenca'] as String?) ?? '';
    final nome = (map['nome'] as String?) ?? '';

    // Mensalidade e capacidade por período ainda não existem no Firestore —
    // gera uma variação mockada, porém estável (mesmo motorista sempre com
    // os mesmos valores), derivada do nome, só pra não ficar tudo idêntico.
    final semente = nome.isEmpty ? 0 : nome.codeUnits.fold<int>(0, (soma, c) => soma + c);

    return Motorista(
      nome: nome,
      corridas: '',
      tempo: '',
      crm: licenca.isNotEmpty ? licenca : '---',
      fotoPerfil: '',
      veiculo: veiculo.isNotEmpty ? veiculo : 'Veículo não informado',
      placa: placa.isNotEmpty ? placa : '---',
      valorMensalidade: 280.0 + (semente % 6) * 20,
      criancasManha: 1 + (semente % 4),
      criancasTarde: (semente ~/ 4) % 4,
    );
  }
}