class Feriado {
  final DateTime data;
  final String nome;
  final String tipo;

  const Feriado({required this.data, required this.nome, required this.tipo});

  factory Feriado.fromMap(Map<String, dynamic> map) {
    return Feriado(
      data: DateTime.parse(map['date'] as String),
      nome: map['name'] as String? ?? 'Feriado',
      tipo: map['type'] as String? ?? '',
    );
  }

  bool get ehHoje {
    final hoje = DateTime.now();
    return data.year == hoje.year && data.month == hoje.month && data.day == hoje.day;
  }
}
