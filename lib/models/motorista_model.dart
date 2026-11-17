class Motorista {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final String localizacao;
  final String membroDesde;
  final String passageiros;
  final String rotasAtivas;
  final String avaliacao;
  final String corridas;
  final String tempo;
  final String crm;
  final String fotoPerfil;
  final String veiculo;
  final String placa;

  final double valorMensalidade;
  final int criancasManha;
  final int criancasTarde;

  const Motorista({
    this.uid = '',
    required this.nome,
    this.email = '',
    this.telefone = '',
    this.localizacao = 'São Paulo, SP',
    this.membroDesde = 'Jan/2024',
    this.passageiros = '15',
    this.rotasAtivas = '2',
    this.avaliacao = '4,9/5',
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

  factory Motorista.fromMap(Map<String, dynamic> map) {
    return Motorista(
      uid: map['uid'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      localizacao: map['localizacao'] ?? 'São Paulo, SP',
      membroDesde: map['membroDesde'] ?? 'Jan/2024',
      passageiros: map['passageiros'] ?? '15',
      rotasAtivas: map['rotasAtivas'] ?? '2',
      avaliacao: map['avaliacao'] ?? '4,9/5',
      corridas: map['corridas'] ?? '0',
      tempo: map['tempo'] ?? '0',
      crm: map['crm'] ?? '',
      fotoPerfil: map['fotoPerfil'] ?? '',
      veiculo: map['veiculo'] ?? 'Veículo não informado',
      placa: map['placa'] ?? '---',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'localizacao': localizacao,
      'membroDesde': membroDesde,
      'passageiros': passageiros,
      'rotasAtivas': rotasAtivas,
      'avaliacao': avaliacao,
      'corridas': corridas,
      'tempo': tempo,
      'crm': crm,
      'fotoPerfil': fotoPerfil,
      'veiculo': veiculo,
      'placa': placa,
    };
  }

  factory Motorista.fromUsuarioMap(Map<String, dynamic> map) {
    final veiculo = (map['veiculo'] as String?) ?? '';
    final placa = (map['placa'] as String?) ?? '';
    final licenca = (map['licenca'] as String?) ?? '';
    final nome = (map['nome'] as String?) ?? '';
    final fotoPerfil = (map['fotoPerfil'] as String?) ?? '';

    final semente = nome.isEmpty ? 0 : nome.codeUnits.fold<int>(0, (soma, c) => soma + c);

    return Motorista(
      uid: (map['uid'] as String?) ?? '',
      nome: nome,
      corridas: '',
      tempo: '',
      crm: licenca.isNotEmpty ? licenca : '---',
      fotoPerfil: fotoPerfil,
      veiculo: veiculo.isNotEmpty ? veiculo : 'Veículo não informado',
      placa: placa.isNotEmpty ? placa : '---',
      valorMensalidade: 280.0 + (semente % 6) * 20,
      criancasManha: 1 + (semente % 4),
      criancasTarde: (semente ~/ 4) % 4,
    );
  }
}