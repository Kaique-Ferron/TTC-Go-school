import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_1/models/parada_rota.dart';
import 'package:flutter_application_1/services/rota_service.dart';

void main() {
  final servico = RotaService.instance;

  group('RotaService.calcular (sem API externa, só geometria local)', () {
    test('retorna null quando não há paradas', () async {
      final resultado = await servico.calcular(
        partida: const LatLng(-23.5505, -46.6333),
        paradas: const [],
      );
      expect(resultado, isNull);
    });

    test('com uma única parada, a ordem é ela mesma', () async {
      const parada = ParadaRota(id: 'a', label: 'Casa A', posicao: LatLng(-23.56, -46.64));

      final resultado = await servico.calcular(
        partida: const LatLng(-23.5505, -46.6333),
        paradas: const [parada],
      );

      expect(resultado, isNotNull);
      expect(resultado!.ordemParadas, hasLength(1));
      expect(resultado.ordemParadas.first.id, 'a');
      expect(resultado.distanciaKm, greaterThan(0));
      expect(resultado.duracao.inMinutes, greaterThan(0));
    });

    test('escolhe a ordem de menor distância total, não a ordem de entrada', () async {
      // Partida na origem (0,0). Duas paradas na mesma "linha reta": uma
      // perto (B), uma longe (C). Entrando na ordem [longe, perto], o
      // caixeiro-viajante deve inverter pra [perto, longe] — é sempre mais
      // curto visitar a mais perto primeiro quando os três pontos estão
      // alinhados.
      const partida = LatLng(0, 0);
      const perto = ParadaRota(id: 'perto', label: 'Perto', posicao: LatLng(0, 1));
      const longe = ParadaRota(id: 'longe', label: 'Longe', posicao: LatLng(0, 3));

      final resultado = await servico.calcular(
        partida: partida,
        paradas: const [longe, perto], // propositalmente fora de ordem
      );

      expect(resultado, isNotNull);
      expect(resultado!.ordemParadas.map((p) => p.id).toList(), ['perto', 'longe']);
    });

    test('inclui o destino no fim da ordem quando informado', () async {
      const partida = LatLng(0, 0);
      const parada = ParadaRota(id: 'a', label: 'Casa A', posicao: LatLng(0, 1));
      const destino = LatLng(0, 2);

      final resultado = await servico.calcular(
        partida: partida,
        paradas: const [parada],
        destino: destino,
        destinoLabel: 'Escola Teste',
      );

      expect(resultado, isNotNull);
      expect(resultado!.ordemParadas.last.id, 'destino');
      expect(resultado.ordemParadas.last.label, 'Escola Teste');
    });

    test('funciona com mais de 7 paradas (usa o caminho do vizinho mais próximo)', () async {
      final paradas = List.generate(
        9,
        (i) => ParadaRota(id: 'p$i', label: 'Parada $i', posicao: LatLng(0, (i + 1).toDouble())),
      );

      final resultado = await servico.calcular(
        partida: const LatLng(0, 0),
        paradas: paradas,
      );

      expect(resultado, isNotNull);
      expect(resultado!.ordemParadas, hasLength(9));
      // Alinhadas numa reta crescente, o vizinho mais próximo deve manter
      // a ordem natural (p0, p1, ..., p8) — a mais eficiente possível.
      expect(resultado.ordemParadas.map((p) => p.id).toList(), paradas.map((p) => p.id).toList());
    });
  });
}
