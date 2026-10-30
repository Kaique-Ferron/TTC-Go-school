import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/parada_rota.dart';
import '../models/rota_otimizada.dart';

/// Calcula a melhor ordem de embarque das crianças e o trajeto entre elas
/// — tudo resolvido aqui dentro do app, sem nenhuma API de mapas externa
/// (nem chave, nem internet pra essa parte: funciona até offline).
///
/// Como não há acesso a um serviço de roteamento de ruas de verdade (o que
/// exigiria uma base de dados de ruas gigante ou uma API paga), a "melhor
/// ordem" é resolvida como o problema do caixeiro-viajante em cima da
/// distância em linha reta entre as coordenadas (fórmula de haversine — a
/// mesma matemática que todo GPS usa pra medir distância entre dois
/// pontos do globo):
///
/// - até 7 paradas: testa TODAS as ordens possíveis (força bruta) e fica
///   com a de menor distância total — 7! = 5.040 combinações, instantâneo;
/// - mais que isso: usa a heurística do "vizinho mais próximo" (a cada
///   passo, vai pro ponto não visitado mais perto de onde está), que não
///   garante o ótimo absoluto mas continua muito boa pra uma rota de van
///   escolar (poucas dezenas de paradas no máximo).
///
/// A linha desenhada no mapa liga os pontos em reta, na ordem calculada —
/// não contorna quarteirão nem segue mão de rua, é uma estimativa (tempo e
/// distância também são estimados, com uma velocidade média de trânsito
/// urbano). O que importa de verdade — a ORDEM das paradas — é real.
class RotaService {
  RotaService._();
  static final RotaService instance = RotaService._();

  static const double _raioTerraKm = 6371.0;
  static const double _velocidadeMediaKmH = 28.0;

  Future<RotaOtimizada?> calcular({
    required LatLng partida,
    required List<ParadaRota> paradas,
    LatLng? destino,
    String destinoLabel = 'Escola',
  }) async {
    if (paradas.isEmpty) return null;

    final ordem = paradas.length <= 7
        ? _ordemPorForcaBruta(partida, paradas)
        : _ordemPorVizinhoMaisProximo(partida, paradas);

    final pontos = [partida, ...ordem.map((p) => p.posicao), ?destino];

    var distanciaTotalKm = 0.0;
    for (var i = 0; i < pontos.length - 1; i++) {
      distanciaTotalKm += _distanciaKm(pontos[i], pontos[i + 1]);
    }

    return RotaOtimizada(
      ordemParadas: [
        ...ordem,
        if (destino != null) ParadaRota(id: 'destino', label: destinoLabel, posicao: destino),
      ],
      geometria: pontos,
      duracao: Duration(minutes: (distanciaTotalKm / _velocidadeMediaKmH * 60).round()),
      distanciaKm: distanciaTotalKm,
    );
  }

  /// Distância em linha reta entre dois pontos do globo (fórmula de
  /// haversine), em quilômetros.
  double _distanciaKm(LatLng a, LatLng b) {
    final dLat = _paraRadianos(b.latitude - a.latitude);
    final dLng = _paraRadianos(b.longitude - a.longitude);
    final lat1 = _paraRadianos(a.latitude);
    final lat2 = _paraRadianos(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return _raioTerraKm * c;
  }

  double _paraRadianos(double graus) => graus * math.pi / 180;

  List<ParadaRota> _ordemPorForcaBruta(LatLng partida, List<ParadaRota> paradas) {
    List<ParadaRota>? melhorOrdem;
    var menorDistancia = double.infinity;

    for (final permutacao in _permutacoes(paradas)) {
      var distancia = _distanciaKm(partida, permutacao.first.posicao);
      for (var i = 0; i < permutacao.length - 1; i++) {
        distancia += _distanciaKm(permutacao[i].posicao, permutacao[i + 1].posicao);
      }
      if (distancia < menorDistancia) {
        menorDistancia = distancia;
        melhorOrdem = permutacao;
      }
    }
    return melhorOrdem!;
  }

  Iterable<List<ParadaRota>> _permutacoes(List<ParadaRota> itens) sync* {
    if (itens.length <= 1) {
      yield itens;
      return;
    }
    for (var i = 0; i < itens.length; i++) {
      final resto = [...itens]..removeAt(i);
      for (final permutacaoResto in _permutacoes(resto)) {
        yield [itens[i], ...permutacaoResto];
      }
    }
  }

  List<ParadaRota> _ordemPorVizinhoMaisProximo(LatLng partida, List<ParadaRota> paradas) {
    final restantes = [...paradas];
    final ordem = <ParadaRota>[];
    var atual = partida;

    while (restantes.isNotEmpty) {
      restantes.sort((a, b) => _distanciaKm(atual, a.posicao).compareTo(_distanciaKm(atual, b.posicao)));
      final proximo = restantes.removeAt(0);
      ordem.add(proximo);
      atual = proximo.posicao;
    }
    return ordem;
  }
}
