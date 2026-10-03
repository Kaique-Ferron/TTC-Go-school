class Motorista {
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

  const Motorista({
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
  });

  // Converte os dados vindos do Firestore (Map) para o objeto Motorista
  factory Motorista.fromMap(Map<String, dynamic> map) {
    return Motorista(
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

  // Converte o objeto Motorista para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
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
}