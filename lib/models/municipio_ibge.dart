class MunicipioIbge {
  final String nome;
  final String microrregiao;
  final String mesorregiao;
  final String uf;
  final String regiao;

  const MunicipioIbge({
    required this.nome,
    required this.microrregiao,
    required this.mesorregiao,
    required this.uf,
    required this.regiao,
  });

  factory MunicipioIbge.fromMap(Map<String, dynamic> map) {
    final microrregiao = map['microrregiao'] as Map<String, dynamic>?;
    final mesorregiao = microrregiao?['mesorregiao'] as Map<String, dynamic>?;
    final estado = mesorregiao?['UF'] as Map<String, dynamic>?;
    final regiao = estado?['regiao'] as Map<String, dynamic>?;

    return MunicipioIbge(
      nome: map['nome'] as String? ?? '',
      microrregiao: microrregiao?['nome'] as String? ?? '',
      mesorregiao: mesorregiao?['nome'] as String? ?? '',
      uf: estado?['sigla'] as String? ?? '',
      regiao: regiao?['nome'] as String? ?? '',
    );
  }
}
