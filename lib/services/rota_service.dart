import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/parada_rota.dart';
import '../models/rota_otimizada.dart';
import 'rota_real_service.dart';

/// Calcula a melhor ordem de embarque das crianças e o trajeto entre elas.
///
/// A ORDEM das paradas é sempre calculada aqui dentro, sem nenhuma API
/// externa — problema do caixeiro-viajante em cima da distância em linha
/// reta entre coordenadas (fórmula de haversine): até 7 paradas testa
/// todas as ordens possíveis (força bruta), mais que isso usa a
/// heurística do vizinho mais próximo. Isso não precisa de mapa de ruas,
/// só da posição dos pontos, então funciona sempre.
///
/// Já o DESENHO do trajeto no mapa — pra não cortar reto por cima de
/// prédio, rio ou quarteirão inteiro — usa [RotaRealService] (OSRM,
/// gratuito e sem chave). Se não conseguir buscar o trajeto real (sem
/// internet, serviço fora do ar), cai de volta pro traçado em linha reta
/// — a ordem das paradas continua certa de qualquer jeito, só o desenho
/// fica reto.
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
