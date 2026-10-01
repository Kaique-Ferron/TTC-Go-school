class Filho {
  final String? id;
  final String nome;
  final String idadeEAno;
  final String escola;
  final String turno;
  final String horario;
  final String tipoSanguineo;
  final String alergias;
  final String status;

  const Filho({
    this.id,
    required this.nome,
    required this.idadeEAno,
    required this.escola,
    required this.turno,
    required this.horario,
    this.tipoSanguineo = '',
    this.alergias = '',
    this.status = 'Ativo',
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idadeEAno': idadeEAno,
      'escola': escola,
      'turno': turno,
      'horario': horario,
      'tipoSanguineo': tipoSanguineo,
      'alergias': alergias,
      'status': status,
    };
  }

  factory Filho.fromMap(String id, Map<String, dynamic> map) {
    return Filho(
      id: id,
      nome: map['nome'] ?? '',
      idadeEAno: map['idadeEAno'] ?? '',
      escola: map['escola'] ?? '',
      turno: map['turno'] ?? '',
      horario: map['horario'] ?? '',
      tipoSanguineo: map['tipoSanguineo'] ?? '',
      alergias: map['alergias'] ?? '',
      status: map['status'] ?? 'Ativo',
    );
  }
}
