import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/cores.dart';

/// Tela para o Responsável marcar a localização da própria casa no mapa.
/// Salva coordenadas + endereço legível em usuarios/{uid} (casa_lat,
/// casa_lng, casa_endereco), via merge para não sobrescrever o resto do perfil.
class MapaCasaTela extends StatefulWidget {
  final double? latitudeAtual;
  final double? longitudeAtual;

  const MapaCasaTela({super.key, this.latitudeAtual, this.longitudeAtual});

  @override
  State<MapaCasaTela> createState() => _MapaCasaTelaState();
}

class _MapaCasaTelaState extends State<MapaCasaTela> {
  static const LatLng _centroPadrao = LatLng(-23.5505, -46.6333); // São Paulo

  final MapController _mapController = MapController();

  LatLng? _posicaoCasa;
  bool _salvando = false;
  bool _buscandoGps = false;

  @override
  void initState() {
    super.initState();
    if (widget.latitudeAtual != null && widget.longitudeAtual != null) {
      _posicaoCasa = LatLng(widget.latitudeAtual!, widget.longitudeAtual!);
    }
  }

  void _atualizarPino(LatLng ponto) => setState(() => _posicaoCasa = ponto);

  Future<void> _centralizarNaMinhaLocalizacao() async {
    setState(() => _buscandoGps = true);
    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        throw Exception('Ative o serviço de localização do dispositivo.');
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada.');
      }

      final posicao = await Geolocator.getCurrentPosition();
      final ponto = LatLng(posicao.latitude, posicao.longitude);

      setState(() => _posicaoCasa = ponto);
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

  /// Converte a coordenada marcada em um endereço legível (rua, bairro).
  /// Retorna null quando a geocodificação reversa não está disponível
  /// (ex: plataforma Web, sem suporte nativo do pacote geocoding) — nesse
  /// caso a casa ainda é salva, só sem o texto do endereço.
  Future<String?> _enderecoLegivel(LatLng ponto) async {
    try {
      final placemarks = await placemarkFromCoordinates(ponto.latitude, ponto.longitude);
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final partes = [p.thoroughfare, p.subLocality].where((parte) => parte != null && parte.isNotEmpty);
      return partes.isEmpty ? null : partes.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _salvarCasa() async {
    if (_posicaoCasa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toque no mapa para marcar onde fica sua casa antes de salvar.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _salvando = true);
    try {
      final enderecoCasa = await _enderecoLegivel(_posicaoCasa!);

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'casa_lat': _posicaoCasa!.latitude,
        'casa_lng': _posicaoCasa!.longitude,
        if (enderecoCasa != null) 'casa_endereco': enderecoCasa,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização da casa salva com sucesso!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localização da Casa'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _posicaoCasa ?? _centroPadrao,
              initialZoom: _posicaoCasa != null ? 16 : 12,
              onTap: (_, ponto) => _atualizarPino(ponto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              if (_posicaoCasa != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _posicaoCasa!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 44),
                    ),
                  ],
                ),
            ],
          ),

          // Dica de uso
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, size: 18, color: AppCores.azulPrincipal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toque no mapa para marcar onde fica sua casa',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão flutuante: centralizar na posição atual (GPS)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'btn_localizacao_atual',
              backgroundColor: Colors.white,
              foregroundColor: AppCores.azulPrincipal,
              onPressed: _buscandoGps ? null : _centralizarNaMinhaLocalizacao,
              child: _buscandoGps
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
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
              onPressed: _salvando ? null : _salvarCasa,
              icon: _salvando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.home, color: Colors.white),
              label: const Text('Salvar Localização da Casa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
