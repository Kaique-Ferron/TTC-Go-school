class EscolaRota {
  final String nome;
  final double lat;
  final double lng;

  const EscolaRota({required this.nome, required this.lat, required this.lng});

  Map<String, dynamic> toMap() => {'nome': nome, 'lat': lat, 'lng': lng};

  factory EscolaRota.fromMap(Map<String, dynamic> map) {
    return EscolaRota(
      nome: map['nome'] as String? ?? '',
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }
}
