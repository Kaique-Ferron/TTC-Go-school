import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/parada_rota.dart';
import '../models/rota_otimizada.dart';
import 'rota_real_service.dart';

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

    final ordemParadas = [
      ...ordem,
      if (destino != null) ParadaRota(id: 'destino', label: destinoLabel, posicao: destino),
    ];
    final pontos = [partida, ...ordem.map((p) => p.posicao), ?destino];

    final caminhoReal = await RotaRealService.instance.calcularCaminho(pontos);
    if (caminhoReal != null) {
      final (geometriaReal, distanciaRealKm) = caminhoReal;
      return RotaOtimizada(
        ordemParadas: ordemParadas,
        geometria: geometriaReal,
        duracao: Duration(minutes: (distanciaRealKm / _velocidadeMediaKmH * 60).round()),
        distanciaKm: distanciaRealKm,
        trajetoReal: true,
      );
    }

    var distanciaTotalKm = 0.0;
    for (var i = 0; i < pontos.length - 1; i++) {
      distanciaTotalKm += _distanciaKm(pontos[i], pontos[i + 1]);
    }

    return RotaOtimizada(
      ordemParadas: ordemParadas,
      geometria: pontos,
      duracao: Duration(minutes: (distanciaTotalKm / _velocidadeMediaKmH * 60).round()),
      distanciaKm: distanciaTotalKm,
      trajetoReal: false,
    );
  }

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

  /// Corta o trajeto no ponto mais próximo da posição atual, devolvendo só o
  /// trecho que ainda falta percorrer — o trecho já passado "some" do mapa,
  /// em vez de desenhar a linha inteira o tempo todo.
  static List<LatLng> trajetoRestante(List<LatLng> trajeto, LatLng posicaoAtual) {
    if (trajeto.length <= 1) return trajeto;

    var indiceMaisProximo = 0;
    var menorDistancia = double.infinity;
    for (var i = 0; i < trajeto.length; i++) {
      final dLat = trajeto[i].latitude - posicaoAtual.latitude;
      final dLng = trajeto[i].longitude - posicaoAtual.longitude;
      final distancia = dLat * dLat + dLng * dLng;
      if (distancia < menorDistancia) {
        menorDistancia = distancia;
        indiceMaisProximo = i;
      }
    }
    return trajeto.sublist(indiceMaisProximo);
  }

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
