import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/mapa_config.dart';
import '../theme/cores.dart';
import 'badge_icone.dart';
import 'cartao_elevado.dart';

/// Card "Acompanhar rota" do Painel Principal do Responsável.
///
/// Antes mostrava um mapa falso: uma única imagem estática de um tile do
/// OpenStreetMap de um lugar fixo qualquer (nada a ver com o endereço do
/// usuário), com "próxima parada"/horários escritos direto no código.
/// Agora é um mapa real (flutter_map), centrado na localização de casa que
/// o próprio responsável marcou em "Editar Perfil" — e os textos vêm dos
/// dados reais (endereço, escola e horário do filho).
///
/// Não existe (ainda) rastreamento em tempo real da van — isso exigiria o
/// app do Motorista reportando a localização atual pro Firestore, o que é
/// uma funcionalidade maior e separada. Por isso o card mostra o ponto de
/// embarque/desembarque reais, não uma posição "ao vivo" do veículo.
class CardAcompanharRota extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String endereco;
  final String escola;
  final String horario;
  final VoidCallback? onVerDetalhes;

  const CardAcompanharRota({
    super.key,
    this.latitude,
    this.longitude,
    this.endereco = '',
    this.escola = '',
    this.horario = '',
    this.onVerDetalhes,
  });

  bool get _temLocalizacao => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return CartaoElevado(
      corAcento: AppCores.azulPrincipal,
      child: Column(
        children: [
          // Cabeçalho
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

          // Mapa real, centrado na casa do responsável (se já marcada em
          // "Editar Perfil" > "Ponto no Mapa para o Transporte").
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: _temLocalizacao
                  ? Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(latitude!, longitude!),
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
                                Marker(
                                  point: LatLng(latitude!, longitude!),
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                                ),
                              ],
                            ),
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
                      ],
                    )
                  : Container(
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
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Trajeto: casa -> escola, com o horário combinado real (sem
          // etapas/minutos inventados, já que não há rastreamento ao vivo).
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
