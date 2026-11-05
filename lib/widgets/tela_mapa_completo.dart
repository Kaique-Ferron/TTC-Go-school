import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/mapa_config.dart';
import '../theme/cores.dart';

/// Mapa em tela cheia, com botões explícitos de zoom (+/-) além do
/// beliscar/rolar o mouse padrão do flutter_map — aberto ao tocar num
/// mapa pequeno embutido (preview de rota do Motorista, card do
/// Responsável), pra dar espaço de verdade pra olhar o trajeto e deixar
/// claro que dá pra aumentar/diminuir o zoom.
class TelaMapaCompleto extends StatefulWidget {
  final String titulo;
  final List<LatLng> pontosParaEnquadrar;
  final List<Marker> marcadores;
  final List<Polyline> trajetos;

  const TelaMapaCompleto({
    super.key,
    this.titulo = 'Mapa',
    required this.pontosParaEnquadrar,
    this.marcadores = const [],
    this.trajetos = const [],
  });

  @override
  State<TelaMapaCompleto> createState() => _TelaMapaCompletoState();
}

class _TelaMapaCompletoState extends State<TelaMapaCompleto> {
  final MapController _mapController = MapController();

  void _zoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + delta).clamp(2, 19));
  }

  @override
  Widget build(BuildContext context) {
    final pontos = widget.pontosParaEnquadrar;
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: pontos.length > 1
                  ? CameraFit.coordinates(coordinates: pontos, padding: const EdgeInsets.all(40))
                  : null,
              initialCenter: pontos.isNotEmpty ? pontos.first : const LatLng(-23.5505, -46.6333),
              initialZoom: pontos.length == 1 ? 15 : 13,
            ),
            children: [
              TileLayer(urlTemplate: MapaConfig.tileUrlTemplate, userAgentPackageName: 'com.example.flutter_application_1'),
              if (widget.trajetos.isNotEmpty) PolylineLayer(polylines: widget.trajetos),
              MarkerLayer(markers: widget.marcadores),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                _botaoZoom(Icons.add, () => _zoom(1)),
                const SizedBox(height: 10),
                _botaoZoom(Icons.remove, () => _zoom(-1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoZoom(IconData icone, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icone, size: 22, color: AppCores.azulPrincipal),
        ),
      ),
    );
  }
}
