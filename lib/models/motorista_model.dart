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

  /// Converte um documento real de `usuarios` (tipoPerfil: 'motorista') em
  /// Motorista para exibição na aba Serviços — esse documento não tem
  /// 'corridas'/'tempo' (estatísticas que ainda não são rastreadas), então
  /// ficam vazios e a UI esconde essa linha quando não há dado.
  factory Motorista.fromUsuarioMap(Map<String, dynamic> map) {
    final veiculo = (map['veiculo'] as String?) ?? '';
    final placa = (map['placa'] as String?) ?? '';
    final licenca = (map['licenca'] as String?) ?? '';
    return Motorista(
      nome: map['nome'] ?? '',
      corridas: '',
      tempo: '',
      crm: licenca.isNotEmpty ? licenca : '---',
      fotoPerfil: '',
      veiculo: veiculo.isNotEmpty ? veiculo : 'Veículo não informado',
      placa: placa.isNotEmpty ? placa : '---',
    );
  }
}