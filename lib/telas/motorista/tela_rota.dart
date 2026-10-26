import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/mapa_config.dart';
import '../../config/rotas_config.dart';
import '../../models/parada_motorista.dart';
import '../../models/parada_rota.dart';
import '../../models/rota_otimizada.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/rota_service.dart';
import '../../theme/cores.dart';

/// "Minhas Rotas" do Motorista: calcula a melhor ordem de embarque das
/// crianças do período selecionado, partindo de onde o motorista estiver
/// (ou da localização de casa já marcada), usando a API gratuita do
/// OpenRouteService (ver RotaService/RotasConfig). O trajeto real nas ruas
/// é desenhado no mapa, com a lista de paradas na ordem calculada.
class TelaRota extends StatefulWidget {
  const TelaRota({super.key});

  @override
  State<TelaRota> createState() => _TelaRotaState();
}

class _TelaRotaState extends State<TelaRota> {
  String _periodo = DateTime.now().hour < 12 ? 'Manhã' : 'Tarde';
  LatLng? _partida;
  bool _buscandoPartida = false;
  bool _calculando = false;
  String? _erro;
  RotaOtimizada? _rota;

  @override
  void initState() {
    super.initState();
    _carregarPartidaPadrao();
  }

  /// Usa a localização de casa já marcada em Editar Perfil (se houver) como
  /// ponto de partida padrão — o motorista pode trocar por "Usar minha
  /// localização atual" (GPS) a qualquer momento.
  Future<void> _carregarPartidaPadrao() async {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final dados = doc.data();
    final lat = (dados?['casa_lat'] as num?)?.toDouble();
    final lng = (dados?['casa_lng'] as num?)?.toDouble();
    if (lat != null && lng != null && mounted) {
      setState(() => _partida = LatLng(lat, lng));
    }
  }

  Future<void> _usarLocalizacaoAtual() async {
    setState(() => _buscandoPartida = true);
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
      if (!mounted) return;
      setState(() => _partida = LatLng(posicao.latitude, posicao.longitude));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter sua localização: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _buscandoPartida = false);
    }
  }

  Future<void> _calcularRota(List<ParadaMotorista> paradas) async {
    if (_partida == null) {
      setState(() => _erro = 'Defina o ponto de partida antes de calcular.');
      return;
    }
    final comLocalizacao = paradas.where((p) => p.temLocalizacao).toList();
    if (comLocalizacao.isEmpty) {
      setState(() => _erro = 'Nenhuma das paradas desse período tem localização marcada ainda.');
      return;
    }

    setState(() {
      _calculando = true;
      _erro = null;
      _rota = null;
    });

    final resultado = await RotaService.instance.calcular(
      partida: _partida!,
      paradas: comLocalizacao
          .map((p) => ParadaRota(id: p.responsavelUid, label: p.responsavelNome, posicao: p.posicao))
          .toList(),
    );

    if (!mounted) return;
    setState(() {
      _calculando = false;
      _rota = resultado;
      if (resultado == null) _erro = 'Não foi possível calcular a rota agora. Tente de novo em instantes.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        appBar: AppBar(title: const Text('Minhas Rotas')),
        body: const Center(child: Text('Utilizador não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(title: const Text('Minhas Rotas')),
      body: StreamBuilder<List<ParadaMotorista>>(
        stream: FirestoreService.instance.paradasRotaStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todas = snapshot.data ?? [];
          final paradas = todas.where((p) => p.periodo == _periodo).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSeletorPeriodo(context),
                const SizedBox(height: 16),
                _buildPartida(context),
                const SizedBox(height: 16),
                if (!RotasConfig.temChave) _buildAviso(context, 'Chave da API de rotas não configurada — dá pra ver as paradas, mas não calcular o trajeto ainda.'),
                if (paradas.isEmpty)
                  _buildAviso(context, 'Nenhuma criança no período "$_periodo" ainda.')
                else ...[
                  Text(
                    '${paradas.length} parada(s) nesse período',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (!RotasConfig.temChave || _calculando) ? null : () => _calcularRota(paradas),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppCores.laranjaMotorista,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _calculando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.alt_route, color: Colors.white, size: 18),
                      label: Text(
                        _calculando ? 'Calculando...' : 'Calcular melhor rota',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 10),
                    _buildAviso(context, _erro!, cor: Colors.red),
                  ],
                  const SizedBox(height: 16),
                  if (_rota != null) _buildMapaResultado(context, _rota!) else _buildListaSimples(context, paradas),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeletorPeriodo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Row(
        children: ['Manhã', 'Tarde'].map((opcao) {
          final selecionado = opcao == _periodo;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _periodo = opcao;
                _rota = null;
                _erro = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selecionado ? AppCores.laranjaMotorista : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    opcao,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                      color: selecionado ? Colors.white : AppCores.textoPrincipal(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPartida(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location, size: 18, color: AppCores.textoSecundario(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _partida != null
                  ? 'Ponto de partida definido (${_partida!.latitude.toStringAsFixed(4)}, ${_partida!.longitude.toStringAsFixed(4)})'
                  : 'Nenhum ponto de partida definido',
              style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
            ),
          ),
          TextButton(
            onPressed: _buscandoPartida ? null : _usarLocalizacaoAtual,
            child: _buscandoPartida
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Usar GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAviso(BuildContext context, String texto, {Color? cor}) {
    final corFinal = cor ?? AppCores.textoSecundario(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFinal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corFinal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: corFinal),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: TextStyle(fontSize: 12, color: corFinal))),
        ],
      ),
    );
  }

  Widget _buildListaSimples(BuildContext context, List<ParadaMotorista> paradas) {
    return Column(
      children: paradas.map((p) => _buildLinhaParada(context, numero: null, parada: p)).toList(),
    );
  }

  Widget _buildMapaResultado(BuildContext context, RotaOtimizada rota) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.coordinates(coordinates: rota.geometria, padding: const EdgeInsets.all(30)),
              ),
              children: [
                TileLayer(urlTemplate: MapaConfig.tileUrlTemplate, userAgentPackageName: 'com.example.flutter_application_1'),
                PolylineLayer(polylines: [Polyline(points: rota.geometria, strokeWidth: 4, color: AppCores.azulPrincipal)]),
                MarkerLayer(
                  markers: [
                    for (var i = 0; i < rota.ordemParadas.length; i++)
                      Marker(
                        point: rota.ordemParadas[i].posicao,
                        width: 30,
                        height: 30,
                        child: CircleAvatar(
                          backgroundColor: AppCores.laranjaMotorista,
                          child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: AppCores.textoSecundario(context)),
            const SizedBox(width: 4),
            Text('${rota.duracao.inMinutes} min', style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context))),
            const SizedBox(width: 16),
            Icon(Icons.route, size: 14, color: AppCores.textoSecundario(context)),
            const SizedBox(width: 4),
            Text('${rota.distanciaKm.toStringAsFixed(1)} km', style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context))),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < rota.ordemParadas.length; i++)
          _buildLinhaParadaOtimizada(context, numero: i + 1, label: rota.ordemParadas[i].label),
      ],
    );
  }

  Widget _buildLinhaParadaOtimizada(BuildContext context, {required int numero, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: AppCores.laranjaMotorista, child: Text('$numero', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppCores.textoPrincipal(context)))),
        ],
      ),
    );
  }

  Widget _buildLinhaParada(BuildContext context, {required int? numero, required ParadaMotorista parada}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppCores.laranjaMotorista.withValues(alpha: 0.12),
            child: Icon(Icons.home_outlined, color: AppCores.laranjaMotorista, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parada.responsavelNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(parada.filhosNomes.join(', '), style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context))),
                if (!parada.temLocalizacao)
                  Text('Sem localização marcada', style: TextStyle(fontSize: 11, color: Colors.red.shade400, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
