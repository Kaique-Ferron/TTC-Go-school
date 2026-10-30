import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../config/mapa_config.dart';
import '../theme/cores.dart';

/// Tela genérica pra marcar um ponto no mapa — ao contrário de
/// MapaCasaTela (que já salva direto em usuarios/{uid}.casa_lat/lng), essa
/// aqui só devolve a coordenada escolhida via Navigator.pop(context,
/// LatLng(...)); quem chamou decide onde guardar (ex.: a localização da
/// escola de um filho, em usuarios/{uid}/filhos/{filhoId}).
class TelaSelecionarLocal extends StatefulWidget {
  final String titulo;
  final String dica;
  final double? latitudeAtual;
  final double? longitudeAtual;

  const TelaSelecionarLocal({
    super.key,
    required this.titulo,
    this.dica = 'Toque no mapa para marcar o local',
    this.latitudeAtual,
    this.longitudeAtual,
  });

  @override
  State<TelaSelecionarLocal> createState() => _TelaSelecionarLocalState();
}

class _TelaSelecionarLocalState extends State<TelaSelecionarLocal> {
  static const LatLng _centroPadrao = LatLng(-23.5505, -46.6333); // São Paulo

  final MapController _mapController = MapController();
  LatLng? _posicao;
  bool _buscandoGps = false;

  @override
  void initState() {
    super.initState();
    if (widget.latitudeAtual != null && widget.longitudeAtual != null) {
      _posicao = LatLng(widget.latitudeAtual!, widget.longitudeAtual!);
    }
  }

  Future<void> _centralizarNaMinhaLocalizacao() async {
    setState(() => _buscandoGps = true);
    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) throw Exception('Ative o serviço de localização do dispositivo.');

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada.');
      }

      final posicao = await Geolocator.getCurrentPosition();
      final ponto = LatLng(posicao.latitude, posicao.longitude);
      setState(() => _posicao = ponto);
      _mapController.move(ponto, 16.0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter sua localização: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _buscandoGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _posicao ?? _centroPadrao,
              initialZoom: _posicao != null ? 16 : 12,
              onTap: (_, ponto) => setState(() => _posicao = ponto),
            ),
            children: [
              TileLayer(
                urlTemplate: MapaConfig.tileUrlTemplate,
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              if (_posicao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _posicao!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 44),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppCores.superficie(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, size: 18, color: AppCores.azulPrincipal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.dica,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppCores.textoPrincipal(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'btn_localizacao_atual_selecionar_local',
              backgroundColor: Colors.white,
              foregroundColor: AppCores.azulPrincipal,
              onPressed: _buscandoGps ? null : _centralizarNaMinhaLocalizacao,
              child: _buscandoGps
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.azulPrincipal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _posicao == null ? null : () => Navigator.pop(context, _posicao),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Confirmar localização', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
