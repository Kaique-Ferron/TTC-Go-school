import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../repositories/motorista_repository.dart';
import '../../widgets/motorista_card.dart';

// ============================================================================
// CONTEÚDO DA ABA 0: INÍCIO (Com o botão que muda o front inteiro)
// ============================================================================
class AbaInicio extends StatelessWidget {
  final VoidCallback aoClicarEncontrar;

  const AbaInicio({super.key, required this.aoClicarEncontrar});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFE8EEFC), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF1D58E2), size: 16),
                SizedBox(width: 6),
                Text('Motoristas 100% Verificados', style: TextStyle(color: Color(0xFF1D58E2), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'A segurança do seu filho\nna palma da sua mão',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.25),
          ),
          const SizedBox(height: 14),
          const Text(
            'Acompanhe o trajeto de ida e volta da escola em tempo real e tenha paz de espírito todos os dias.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 26),

          // Botão que dispara a troca para a ListView de motoristas
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: aoClicarEncontrar,
            icon: const Icon(Icons.directions_bus_rounded, size: 20),
            label: const Text('Encontrar uma Van', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 32),

          // Cartão com o mapa real (OpenStreetMap, sem chave de API)
          const _MapaTrajeto(),

          const SizedBox(height: 28),

          // Mini estatísticas de confiança
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildEstatistica('50+', 'Motoristas\nverificados')),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(child: _buildEstatistica('500+', 'Famílias\natendidas')),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(child: _buildEstatistica('4.9 ★', 'Avaliação\nmédia')),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEstatistica(String numero, String rotulo) {
    return Column(
      children: [
        Text(numero, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1D58E2))),
        const SizedBox(height: 4),
        Text(
          rotulo,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: Colors.grey[600], height: 1.3),
        ),
      ],
    );
  }
}

// ============================================================================
// MAPA REAL (OpenStreetMap via flutter_map — gratuito, sem chave de API)
// Mostra o trajeto ilustrativo entre a casa do responsável e a escola.
// ============================================================================
class _MapaTrajeto extends StatelessWidget {
  const _MapaTrajeto();

  static const LatLng _casa = LatLng(-23.5610, -46.6560);
  static const LatLng _escola = LatLng(-23.5505, -46.6333);
  static const LatLng _van = LatLng(-23.5570, -46.6440);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _van,
                initialZoom: 13.5,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  // Tiles da CARTO (base em dados do OpenStreetMap) — gratuito, sem
                  // chave de API, e com CORS liberado (o servidor cru do OSM não
                  // libera CORS de forma confiável para apps rodando no navegador).
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.flutter_application_1',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(points: const [_casa, _van, _escola], strokeWidth: 3, color: const Color(0xFF1D58E2)),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _casa,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.home_rounded, color: Color(0xFF1D58E2), size: 26),
                    ),
                    Marker(
                      point: _escola,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.school_rounded, color: Color(0xFF1D58E2), size: 26),
                    ),
                    Marker(
                      point: _van,
                      width: 34,
                      height: 34,
                      child: const Icon(Icons.directions_bus_rounded, color: Color(0xFFFF5C00), size: 30),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFFF5722), size: 16),
                    SizedBox(width: 4),
                    Text('GPS Ativo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.only(right: 4),
                child: const Text(
                  '© OpenStreetMap · © CARTO',
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CONTEÚDO DA ABA 1: SERVIÇOS (ListView Completa dos Motoristas)
// ============================================================================
class AbaMotoristas extends StatelessWidget {
  const AbaMotoristas({super.key});

  @override
  Widget build(BuildContext context) {
    final motoristas = MotoristaRepository.obterMotoristas();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motoristas Disponíveis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text('Todos verificados e avaliados pela comunidade.', style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
          const SizedBox(height: 18),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: motoristas.length,
            itemBuilder: (context, index) => MotoristaCard(motorista: motoristas[index]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
