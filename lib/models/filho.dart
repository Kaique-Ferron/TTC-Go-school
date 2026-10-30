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
  // Localização da escola marcada no mapa (ver CadastrarFilhoTela) — sem
  // isso, a rota do motorista não tem como saber pra onde ir depois de
  // pegar as crianças (o nome digitado sozinho não dá coordenada
  // nenhuma). Nulos em cadastros feitos antes dessa funcionalidade existir.
  final double? escolaLat;
  final double? escolaLng;

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
    this.escolaLat,
    this.escolaLng,
  });

  bool get temLocalizacaoEscola => escolaLat != null && escolaLng != null;

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
      'escolaLat': escolaLat,
      'escolaLng': escolaLng,
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
      escolaLat: (map['escolaLat'] as num?)?.toDouble(),
      escolaLng: (map['escolaLng'] as num?)?.toDouble(),
    );
  }
}
