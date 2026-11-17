import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/cores.dart';

class CamadaVanAnimada extends StatefulWidget {
  final LatLng posicao;

  /// Quanto tempo o ícone leva pra deslizar da posição antiga pra nova.
  /// Ideal deixar igual (ou um pouco menor) que o intervalo real entre
  /// atualizações de localização, pra o movimento ficar contínuo em vez de
  /// "andar e parar".
  final Duration duration;

  const CamadaVanAnimada({
    super.key,
    required this.posicao,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<CamadaVanAnimada> createState() => _CamadaVanAnimadaState();
}

class _CamadaVanAnimadaState extends State<CamadaVanAnimada> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late LatLng _origem;
  late LatLng _destino;

  @override
  void initState() {
    super.initState();
    _origem = widget.posicao;
    _destino = widget.posicao;
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(CamadaVanAnimada oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.posicao != oldWidget.posicao) {

      _origem = _posicaoNoInstante(_controller.value);
      _destino = widget.posicao;
      _controller
        ..stop()
        ..value = 0
        ..forward();
    }
  }

  LatLng _posicaoNoInstante(double t) {
    final suave = Curves.easeInOut.transform(t);
    return LatLng(
      _origem.latitude + (_destino.latitude - _origem.latitude) * suave,
      _origem.longitude + (_destino.longitude - _origem.longitude) * suave,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MarkerLayer(
          markers: [
            Marker(
              point: _posicaoNoInstante(_controller.value),
              width: 40,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppCores.azulPrincipal,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x991D58E2), blurRadius: 10)],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
              ),
            ),
          ],
        );
      },
    );
  }
}
