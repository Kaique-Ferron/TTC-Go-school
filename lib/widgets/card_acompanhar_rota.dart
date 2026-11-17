import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/mapa_config.dart';
import '../models/localizacao_motorista.dart';
import '../services/firestore_service.dart';
import '../theme/cores.dart';
import 'badge_icone.dart';
import 'camada_van_animada.dart';
import 'cartao_elevado.dart';

class CardAcompanharRota extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String endereco;
  final String escola;
  final String horario;
  final String? motoristaUid;
  final VoidCallback? onVerDetalhes;

  const CardAcompanharRota({
    super.key,
    this.latitude,
    this.longitude,
    this.endereco = '',
    this.escola = '',
    this.horario = '',
    this.motoristaUid,
    this.onVerDetalhes,
  });

  bool get _temLocalizacao => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return CartaoElevado(
      corAcento: AppCores.azulPrincipal,
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const BadgeIcone(icone: Icons.map_outlined, cor: AppCores.azulPrincipal, tamanho: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Acompanhar rota',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppCores.textoPrincipal(context),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onVerDetalhes,
                child: const Row(
                  children: [
                    Text('Ver detalhes', style: TextStyle(fontSize: 12, color: AppCores.azulPrincipal, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 16, color: AppCores.azulPrincipal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          InkWell(
            borderRadius: BorderRadius.circular(16),

            onTap: onVerDetalhes,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: (motoristaUid != null && motoristaUid!.isNotEmpty)
                    ? StreamBuilder<LocalizacaoMotorista?>(
                        stream: FirestoreService.instance.localizacaoAtivaStream(motoristaUid!),
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
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEtapaLinha(context, 'Casa', endereco.isEmpty ? '—' : endereco, Icons.home_outlined, AppCores.laranjaMotorista),
              _buildDivisorLinha(context),
              _buildEtapaLinha(context, 'Escola', escola.isEmpty ? '—' : escola, Icons.school_outlined, AppCores.azulPrincipal),
            ],
          ),
          if (horario.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 14, color: AppCores.textoSecundario(context)),
                const SizedBox(width: 4),
                Text(
                  'Horário combinado: $horario',
                  style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapa(BuildContext context, LatLng? posicaoVan) {
    if (!_temLocalizacao && posicaoVan == null) {
      return Container(
        color: AppCores.fundo(context),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pin_drop_outlined, color: AppCores.textoSecundario(context), size: 28),
            const SizedBox(height: 6),
            Text(
              'Marque sua localização em Editar Perfil para ver o mapa da rota',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context)),
            ),
          ],
        ),
      );
    }

    final pontos = [
      if (_temLocalizacao) LatLng(latitude!, longitude!),
      ?posicaoVan,
    ];

    return Stack(
      children: [
        FlutterMap(
          options: pontos.length > 1
              ? MapOptions(
                  initialCameraFit: CameraFit.coordinates(coordinates: pontos, padding: const EdgeInsets.all(28)),
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                )
              : MapOptions(
                  initialCenter: pontos.first,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
          children: [
            TileLayer(
              urlTemplate: MapaConfig.tileUrlTemplate,
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            MarkerLayer(
              markers: [
                if (_temLocalizacao)
                  Marker(
                    point: LatLng(latitude!, longitude!),
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
              ],
            ),
            if (posicaoVan != null)
              CamadaVanAnimada(posicao: posicaoVan, duration: const Duration(milliseconds: 4500)),
          ],
        ),
        if (endereco.isNotEmpty)
          Positioned(
            top: 10,
            left: 10,
            child: _badge(
              icon: Icons.location_on,
              corIcone: Colors.amber,
              rotulo: 'Ponto de embarque',
              valor: endereco,
            ),
          ),
        if (posicaoVan != null)
          const Positioned(
            top: 10,
            right: 10,
            child: _PillAoVivo(),
          ),
      ],
    );
  }

  Widget _badge({
    required IconData icon,
    required Color corIcone,
    required String rotulo,
    required String valor,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: corIcone),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rotulo, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                Text(
                  valor,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtapaLinha(BuildContext context, String rotulo, String valor, IconData icone, Color cor) {
    final corIcone = AppCores.corIconeLegivel(context, cor);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: corIcone.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icone, size: 14, color: corIcone),
          ),
          const SizedBox(height: 4),
          Text(rotulo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context))),
          Text(
            valor,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: 10, color: AppCores.textoSecundario(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisorLinha(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_forward, size: 16, color: AppCores.borda(context)),
    );
  }
}

class _PillAoVivo extends StatelessWidget {
  const _PillAoVivo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.redAccent),
          SizedBox(width: 4),
          Text('Ao vivo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
