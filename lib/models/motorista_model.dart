class Motorista {
  final String nome;
  final String corridas;
  final String tempo;
  final String crm;
  final String fotoPerfil;
  final String veiculo; // Novo campo
  final String placa;   // Novo campo

  const Motorista({
    required this.nome,
    required this.corridas,
    required this.tempo,
    required this.crm,
    required this.fotoPerfil,
    this.veiculo = 'Veículo não informado',
    this.placa = '---',
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
}