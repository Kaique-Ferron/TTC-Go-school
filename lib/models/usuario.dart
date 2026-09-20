class Usuario {
  final String nome;
  final String email;
  final String telefone;
  final String cpf;
  final String perfil; // 'Responsável' ou 'Motorista' (exibição)
  final String cep;
  final String rua;
  final String numero;
  final String bairro;
  final String cnh;
  final String licenca;
  final String placa;
  final String veiculo; // 1. Declaração do campo

  const Usuario({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.perfil,
    this.cep = '',
    this.rua = '',
    this.numero = '',
    this.bairro = '',
    this.cnh = '',
    this.licenca = '',
    this.placa = '',
    this.veiculo = '', // 2. Parâmetro no construtor
  });

  /// Valor normalizado do perfil para gravar no Firestore
  /// (campo 'tipoPerfil'): 'responsavel' ou 'motorista'.
  String get tipoPerfil => perfil == 'Responsável' ? 'responsavel' : 'motorista';

  static String _exibirPerfil(String tipoPerfil) =>
      tipoPerfil == 'motorista' ? 'Motorista' : 'Responsável';

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'tipoPerfil': tipoPerfil,
      'cep': cep,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cnh': cnh,
      'licenca': licenca,
      'placa': placa,
      'veiculo': veiculo, // 3. Adicionado ao toMap
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      cpf: map['cpf'] ?? '',
      perfil: _exibirPerfil(map['tipoPerfil'] ?? 'responsavel'),
      cep: map['cep'] ?? '',
      rua: map['rua'] ?? '',
      numero: map['numero'] ?? '',
      bairro: map['bairro'] ?? '',
      cnh: map['cnh'] ?? '',
      licenca: map['licenca'] ?? '',
      placa: map['placa'] ?? '',
      veiculo: map['veiculo'] ?? '', // 4. Adicionado ao fromMap
    );
  }
}