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
  final String tema; // 'Claro', 'Escuro' ou 'Automático'
  final String tamanhoFonte; // 'Pequena', 'Média' ou 'Grande'
  final String fotoPerfil; // URL do Firebase Storage, vazio se nunca enviou

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
    this.tema = 'Automático',
    this.tamanhoFonte = 'Média',
    this.fotoPerfil = '',
  });

  /// Valor normalizado do perfil para gravar no Firestore
  /// (campo 'tipoPerfil'): 'responsavel' ou 'motorista'.
  String get tipoPerfil =>
      perfil == 'Responsável' ? 'responsavel' : 'motorista';

  /// Endereço combinado em uma única string (rua, número - bairro), usado
  /// pela TelaPerfil/EditarPerfilTela, que leem o campo 'endereco' pronto.
  String get enderecoCompleto {
    final partes = <String>[];
    if (rua.isNotEmpty) partes.add(numero.isNotEmpty ? '$rua, $numero' : rua);
    if (bairro.isNotEmpty) partes.add(bairro);
    return partes.join(' - ');
  }

  static String _exibirPerfil(String tipoPerfil) =>
      tipoPerfil == 'motorista' ? 'Motorista' : 'Responsável';

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'tipoPerfil': tipoPerfil,
      'endereco': enderecoCompleto,
      'cep': cep,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cnh': cnh,
      'licenca': licenca,
      'placa': placa,
      'veiculo': veiculo, // 3. Adicionado ao toMap
      'tema': tema,
      'tamanhoFonte': tamanhoFonte,
      'fotoPerfil': fotoPerfil,
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
      tema: map['tema'] ?? 'Automático',
      tamanhoFonte: map['tamanhoFonte'] ?? 'Média',
      fotoPerfil: map['fotoPerfil'] ?? '',
    );
  }
}
