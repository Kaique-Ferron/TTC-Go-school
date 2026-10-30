import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/mapa_config.dart';
import '../../models/localizacao_motorista.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';

/// Tela de detalhes da rota, aberta a partir do Painel Principal ("Ver
/// detalhes" / card "Transporte em andamento") — mapa grande e de verdade
/// interativo (dá pra arrastar/dar zoom, diferente da prévia pequena do
/// card), com a van ao vivo se o motorista estiver com uma corrida ativa,
/// e um botão pra recentralizar o mapa nela a qualquer momento.
class TelaDetalhesRota extends StatefulWidget {
  final String? motoristaUid;
  final String motoristaNome;
  final double? latitude;
  final double? longitude;
  final String endereco;
  final String escola;
  final String horario;
  final String veiculoEPlaca;

  const TelaDetalhesRota({
    super.key,
    this.motoristaUid,
    this.motoristaNome = '',
    this.latitude,
    this.longitude,
    this.endereco = '',
    this.escola = '',
    this.horario = '',
    this.veiculoEPlaca = '',
  });

  @override
  State<TelaDetalhesRota> createState() => _TelaDetalhesRotaState();
}

class _TelaDetalhesRotaState extends State<TelaDetalhesRota> {
  final MapController _mapController = MapController();

  bool get _temCasa => widget.latitude != null && widget.longitude != null;

  void _localizarVan(LatLng posicaoVan) {
    _mapController.move(posicaoVan, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(title: const Text('Detalhes da rota')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: (widget.motoristaUid != null && widget.motoristaUid!.isNotEmpty)
                ? StreamBuilder<LocalizacaoMotorista?>(
                    stream: FirestoreService.instance.localizacaoAtivaStream(widget.motoristaUid!),
                    builder: (context, snapshot) {
                      final localizacao = snapshot.data;
                      final posicaoVan = (localizacao != null && localizacao.emRota)
                          ? LatLng(localizacao.lat, localizacao.lng)
                          : null;
                      return _buildMapa(context, posicaoVan);
                    },
                  )
                : _buildMapa(context, null),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppCores.superficie(context),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6))],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.motoristaNome.isNotEmpty) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppCores.laranjaMotorista.withValues(alpha: 0.14),
                            child: const Icon(Icons.directions_bus, color: AppCores.laranjaMotorista),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.motoristaNome, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppCores.textoPrincipal(context))),
                                if (widget.veiculoEPlaca.isNotEmpty)
                                  Text(widget.veiculoEPlaca, style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                    _buildLinhaInfo(context, Icons.home_outlined, 'Ponto de embarque', widget.endereco),
                    _buildLinhaInfo(context, Icons.school_outlined, 'Escola', widget.escola),
                    _buildLinhaInfo(context, Icons.access_time, 'Horário combinado', widget.horario),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa(BuildContext context, LatLng? posicaoVan) {
    if (!_temCasa && posicaoVan == null) {
      return Container(
        color: AppCores.fundo(context),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pin_drop_outlined, color: AppCores.textoSecundario(context), size: 36),
            const SizedBox(height: 8),
            Text(
              'Marque sua localização em Editar Perfil para ver o mapa da rota',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppCores.textoSecundario(context)),
            ),
          ],
        ),
      );
    }

    final pontos = [
      if (_temCasa) LatLng(widget.latitude!, widget.longitude!),
      ?posicaoVan,
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: pontos.length > 1
              ? MapOptions(initialCameraFit: CameraFit.coordinates(coordinates: pontos, padding: const EdgeInsets.all(60)))
              : MapOptions(initialCenter: pontos.first, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: MapaConfig.tileUrlTemplate,
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            MarkerLayer(
              markers: [
                if (_temCasa)
                  Marker(
                    point: LatLng(widget.latitude!, widget.longitude!),
                    width: 46,
                    height: 46,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 42),
                  ),
                if (posicaoVan != null)
                  Marker(
                    point: posicaoVan,
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
            ),
          ],
        ),
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: posicaoVan != null ? Colors.redAccent : Colors.grey),
                const SizedBox(width: 6),
                Text(
                  posicaoVan != null ? 'Ao vivo' : 'Sem corrida no momento',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        // Botão "localizar motorista" — recentraliza o mapa na van sem
        // precisar arrastar manualmente, igual o botão de "minha
        // localização" de qualquer app de mapa. Só aparece quando há uma
        // posição ao vivo de verdade pra ir.
        if (posicaoVan != null)
          Positioned(
            bottom: 14,
            right: 14,
            child: FloatingActionButton.small(
              heroTag: 'localizarVan',
              backgroundColor: AppCores.azulPrincipal,
              onPressed: () => _localizarVan(posicaoVan),
              child: const Icon(Icons.directions_bus, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildLinhaInfo(BuildContext context, IconData icone, String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: AppCores.textoSecundario(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context))),
                Text(
                  valor.isEmpty ? '—' : valor,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppCores.textoPrincipal(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
