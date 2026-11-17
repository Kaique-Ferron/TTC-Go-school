class Clima {
  final double temperatura;
  final double velocidadeVento;
  final int codigoTempo;

  const Clima({
    required this.temperatura,
    required this.velocidadeVento,
    required this.codigoTempo,
  });

  factory Clima.fromMap(Map<String, dynamic> map) {
    return Clima(
      temperatura: (map['temperature'] as num).toDouble(),
      velocidadeVento: (map['windspeed'] as num?)?.toDouble() ?? 0,
      codigoTempo: (map['weathercode'] as num).toInt(),
    );
  }

  // Códigos de tempo do padrão WMO usado pela Open-Meteo.
  String get emoji {
    if (codigoTempo == 0) return '☀️';
    if (codigoTempo <= 3) return '⛅';
    if (codigoTempo == 45 || codigoTempo == 48) return '🌫️';
    if (codigoTempo >= 51 && codigoTempo <= 67) return '🌦️';
    if (codigoTempo >= 71 && codigoTempo <= 77) return '🌨️';
    if (codigoTempo >= 80 && codigoTempo <= 82) return '🌧️';
    if (codigoTempo >= 95) return '⛈️';
    return '🌤️';
  }

  String get descricao {
    if (codigoTempo == 0) return 'Céu limpo';
    if (codigoTempo <= 3) return 'Parcialmente nublado';
    if (codigoTempo == 45 || codigoTempo == 48) return 'Neblina';
    if (codigoTempo >= 51 && codigoTempo <= 67) return 'Chuvisco';
    if (codigoTempo >= 71 && codigoTempo <= 77) return 'Neve';
    if (codigoTempo >= 80 && codigoTempo <= 82) return 'Chuva';
    if (codigoTempo >= 95) return 'Tempestade';
    return 'Nublado';
  }

  bool get avisoChuva => (codigoTempo >= 51 && codigoTempo <= 67) || (codigoTempo >= 80);
}
