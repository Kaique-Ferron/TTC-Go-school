import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/mapa_config.dart';
import '../../models/parada_motorista.dart';
import '../../models/parada_rota.dart';
import '../../models/rota_otimizada.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/localizacao_service.dart';
import '../../services/rota_service.dart';
import '../../theme/cores.dart';

/// "Minhas Rotas" do Motorista: calcula a melhor ordem de embarque das
/// crianças do período selecionado, partindo de onde o motorista estiver
/// (ou da localização de casa já marcada). A ORDEM é sempre calculada
/// 100% local (RotaService — caixeiro-viajante em cima da distância entre
/// coordenadas), funciona sempre, sem chave e sem depender de internet. Já
/// o DESENHO do trajeto nas ruas usa o OSRM (ver RotaRealService) —
/// gratuito e sem chave, mas é um serviço de terceiros, não nosso código.
/// Sem internet na hora, ou sem resposta do serviço, cai pro traçado em
/// linha reta, mas a ordem das paradas continua certa de qualquer jeito.
///
/// O mapa é o elemento principal da tela (estilo Waze/GPS de navegação),
/// não uma prévia pequena dentro de uma lista — os controles (corrida,
/// período, lista de paradas) ficam flutuando por cima dele. Com a
/// corrida iniciada, o mapa segue sua posição ao vivo automaticamente.
class TelaRota extends StatefulWidget {
  const TelaRota({super.key});

  @override
  State<TelaRota> createState() => _TelaRotaState();
}

class _TelaRotaState extends State<TelaRota> {
  final MapController _mapController = MapController();

  String _periodo = DateTime.now().hour < 12 ? 'Manhã' : 'Tarde';
  LatLng? _partida;
  bool _buscandoPartida = false;
  bool _calculando = false;
  String? _erro;
  RotaOtimizada? _rota;

  bool _corridaAtiva = false;
  bool _alternandoCorrida = false;

  StreamSubscription<Position>? _assinaturaSeguir;
  bool _primeiroEnquadramentoFeito = false;

  @override
  void initState() {
    super.initState();
    // Se o motorista voltou pra essa tela com a corrida já em andamento
    // (iniciada antes, navegou pra outro lugar e voltou), reflete o estado
    // real em vez de assumir "parado" — e já volta a seguir a posição.
    _corridaAtiva = LocalizacaoService.instance.emAndamento;
    if (_corridaAtiva) _seguirPosicaoAoVivo();
    _carregarPartidaPadrao();
  }

  @override
  void dispose() {
    _assinaturaSeguir?.cancel();
    super.dispose();
  }

  Future<void> _alternarCorrida(String uid) async {
    setState(() => _alternandoCorrida = true);
    try {
      if (_corridaAtiva) {
        await LocalizacaoService.instance.finalizarCorrida(uid);
        _pararDeSeguirPosicao();
        if (mounted) setState(() => _corridaAtiva = false);
      } else {
        final erro = await LocalizacaoService.instance.iniciarCorrida(uid);
        if (!mounted) return;
        if (erro != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red));
        } else {
          setState(() => _corridaAtiva = true);
          _seguirPosicaoAoVivo();
        }
      }
    } finally {
      if (mounted) setState(() => _alternandoCorrida = false);
    }
  }

  /// Mantém a câmera do mapa centrada na posição atual do motorista
  /// enquanto a corrida estiver em andamento — como num app de navegação
  /// de verdade (Waze), em vez de um mapa estático que não acompanha o
  /// movimento. Assinatura própria do GPS (independente da que
  /// LocalizacaoService usa pra reportar a posição pro Firestore).
  void _seguirPosicaoAoVivo() {
    _assinaturaSeguir?.cancel();
    _assinaturaSeguir = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 8),
    ).listen((posicao) {
      if (!mounted) return;
      final ponto = LatLng(posicao.latitude, posicao.longitude);
      setState(() => _partida = ponto);
      try {
        _mapController.move(ponto, _mapController.camera.zoom < 15 ? 17 : _mapController.camera.zoom);
      } catch (_) {
        // Mapa ainda não montou (primeiro frame) — ignora, o próximo
        // reposicionamento resolve.
      }
    });
  }

  void _pararDeSeguirPosicao() {
    _assinaturaSeguir?.cancel();
    _assinaturaSeguir = null;
  }

  /// Usa a localização de casa já marcada (se houver — hoje só o
  /// Responsável tem uma tela pra marcar isso, o Motorista não) como ponto
  /// de partida padrão. Sem isso marcado, busca o GPS automaticamente —
  /// sem essa segunda parte, quem nunca marcou casa nem apertou "Usar GPS"
  /// manualmente abria a tela sem nenhum ponto de partida, e por isso sem
  /// nenhum mapa pra mostrar.
  Future<void> _carregarPartidaPadrao() async {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final dados = doc.data();
    final lat = (dados?['casa_lat'] as num?)?.toDouble();
    final lng = (dados?['casa_lng'] as num?)?.toDouble();
    if (lat != null && lng != null && mounted) {
      setState(() => _partida = LatLng(lat, lng));
      return;
    }
    if (mounted) await _usarLocalizacaoAtual();
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
      _primeiroEnquadramentoFeito = false;
    });

    // Destino final: a escola marcada no cadastro de algum dos filhos
    // dessas paradas (ver Filho.escolaLat/escolaLng e registrarContratacao)
    // — sem isso, a rota só visita as casas e para por aí, sem saber pra
    // onde ir depois.
    final paradaComEscola = comLocalizacao.where((p) => p.temLocalizacaoEscola);
    final destino = paradaComEscola.isEmpty ? null : paradaComEscola.first.posicaoEscola;
    final destinoLabel = paradaComEscola.isEmpty ? 'Escola' : paradaComEscola.first.escolaNome;

    final resultado = await RotaService.instance.calcular(
      partida: _partida!,
      paradas: comLocalizacao
          .map((p) => ParadaRota(id: p.responsavelUid, label: p.responsavelNome, posicao: p.posicao))
          .toList(),
      destino: destino,
      destinoLabel: destinoLabel.isEmpty ? 'Escola' : destinoLabel,
    );

    if (!mounted) return;
    setState(() {
      _calculando = false;
      _rota = resultado;
      if (resultado == null) {
        _erro = 'Não foi possível calcular a rota agora. Tente de novo em instantes.';
      } else if (destino == null) {
        _erro = 'Nenhuma criança desse período tem a localização da escola marcada — a rota termina na última casa. Peça aos responsáveis pra marcar em "Meus Filhos".';
      }
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Minhas Rotas'),
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        foregroundColor: AppCores.laranjaMotorista,
      ),
      body: StreamBuilder<List<ParadaMotorista>>(
        stream: FirestoreService.instance.paradasRotaStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todas = snapshot.data ?? [];
          final paradas = todas.where((p) => p.periodo == _periodo).toList();

          return Stack(
            children: [
              // O MAPA é o elemento principal — ocupa a tela inteira, os
              // controles ficam flutuando por cima dele (estilo Waze),
              // não o contrário (mapa pequeno dentro de uma lista).
              Positioned.fill(child: _buildMapaPrincipal(context, paradas)),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 60, 12, 0),
                    child: _buildBarraSuperior(context, uid),
                  ),
                ),
              ),

              _buildPainelInferior(context, uid, paradas),
            ],
          );
        },
      ),
    );
  }

  /// Barra flutuante com o status/alternância da corrida e o seletor de
  /// período, por cima do mapa.
  Widget _buildBarraSuperior(BuildContext context, String uid) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _corridaAtiva
                  ? [AppCores.verde, AppCores.verde.withValues(alpha: 0.85)]
                  : [AppCores.laranjaMotorista, AppCores.laranjaClaro],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Icon(_corridaAtiva ? Icons.gps_fixed : Icons.gps_off, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _corridaAtiva ? 'Corrida em andamento — seguindo sua posição' : 'Corrida parada',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 30,
                child: _alternandoCorrida
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      )
                    : ElevatedButton(
                        onPressed: () => _alternarCorrida(uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _corridaAtiva ? AppCores.verde : AppCores.laranjaMotorista,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          _corridaAtiva ? 'Finalizar' : 'Iniciar',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))],
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
                    _primeiroEnquadramentoFeito = false;
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
        ),
      ],
    );
  }

  /// O mapa cheio de tela — sempre visível, com o trajeto calculado (ou
  /// só os pinos, antes de calcular) e um botão de recentralizar na sua
  /// posição, igual qualquer app de navegação.
  Widget _buildMapaPrincipal(BuildContext context, List<ParadaMotorista> paradas) {
    final comLocalizacao = paradas.where((p) => p.temLocalizacao).toList();
    final rota = _rota;

    final pontos = rota != null
        ? rota.geometria
        : [if (_partida != null) _partida!, ...comLocalizacao.map((p) => p.posicao)];

    final marcadores = rota != null
        ? [
            for (var i = 0; i < rota.ordemParadas.length; i++)
              Marker(
                point: rota.ordemParadas[i].posicao,
                width: 32,
                height: 32,
                child: rota.ordemParadas[i].id == 'destino'
                    ? const CircleAvatar(
                        backgroundColor: AppCores.azulPrincipal,
                        child: Icon(Icons.school, color: Colors.white, size: 16),
                      )
                    : CircleAvatar(
                        backgroundColor: AppCores.laranjaMotorista,
                        child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
              ),
          ]
        : [
            if (_partida != null)
              Marker(
                point: _partida!,
                width: 36,
                height: 36,
                child: const CircleAvatar(
                  backgroundColor: AppCores.laranjaMotorista,
                  child: Icon(Icons.directions_bus, color: Colors.white, size: 16),
                ),
              ),
            for (final parada in comLocalizacao)
              Marker(
                point: parada.posicao,
                width: 32,
                height: 32,
                child: const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.home, color: Colors.white, size: 16),
                ),
              ),
          ];

    // Linha com "brilho" por baixo (mais larga, translúcida) + linha
    // principal com borda branca e pontas redondas por cima — estilo
    // Google Maps/Uber/Waze, em vez de uma linha lisa de uma cor só.
    final trajetos = rota == null
        ? const <Polyline>[]
        : [
            Polyline(points: rota.geometria, strokeWidth: 11, color: AppCores.laranjaMotorista.withValues(alpha: 0.25)),
            Polyline(
              points: rota.geometria,
              strokeWidth: 5,
              color: AppCores.laranjaMotorista,
              borderStrokeWidth: 2,
              borderColor: Colors.white,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ];

    if (pontos.isEmpty) {
      return Container(
        color: AppCores.superficie(context),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          'Defina seu ponto de partida pra ver o mapa.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppCores.textoSecundario(context)),
        ),
      );
    }

    // Só enquadra automaticamente a rota/pinos na primeira vez que esse
    // conjunto de pontos aparece — depois disso, se a corrida estiver
    // ativa, é o _seguirPosicaoAoVivo que manda na câmera (senão o mapa
    // voltaria a se reenquadrar sozinho a cada rebuild, brigando com o
    // usuário arrastando/dando zoom manualmente).
    if (!_primeiroEnquadramentoFeito) {
      _primeiroEnquadramentoFeito = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          if (pontos.length > 1) {
            _mapController.fitCamera(CameraFit.coordinates(coordinates: pontos, padding: const EdgeInsets.all(60)));
          } else {
            _mapController.move(pontos.first, 16);
          }
        } catch (_) {}
      });
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: pontos.first,
            initialZoom: 15,
          ),
          children: [
            TileLayer(urlTemplate: MapaConfig.tileUrlTemplate, userAgentPackageName: 'com.example.flutter_application_1'),
            if (trajetos.isNotEmpty) PolylineLayer(polylines: trajetos),
            MarkerLayer(markers: marcadores),
          ],
        ),
        Positioned(
          right: 14,
          bottom: 200,
          child: Column(
            children: [
              _botaoMapa(
                _buscandoPartida ? null : Icons.my_location,
                _buscandoPartida
                    ? null
                    : () async {
                        // Sem corrida ativa, ninguém está atualizando sua
                        // posição sozinho — busca o GPS de novo antes de
                        // recentralizar.
                        if (!_corridaAtiva) await _usarLocalizacaoAtual();
                        if (_partida != null) _mapController.move(_partida!, 17);
                      },
              ),
              const SizedBox(height: 10),
              _botaoMapa(Icons.add, () {
                final c = _mapController.camera;
                _mapController.move(c.center, (c.zoom + 1).clamp(2, 19));
              }),
              const SizedBox(height: 8),
              _botaoMapa(Icons.remove, () {
                final c = _mapController.camera;
                _mapController.move(c.center, (c.zoom - 1).clamp(2, 19));
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// [icone] null mostra um spinner no lugar (botão "ocupado", ex.:
  /// buscando o GPS de novo) — nesse caso [onTap] também deve ser null.
  Widget _botaoMapa(IconData? icone, VoidCallback? onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: icone == null
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppCores.laranjaMotorista))
              : Icon(icone, size: 20, color: AppCores.laranjaMotorista),
        ),
      ),
    );
  }

  /// Painel flutuante no fundo da tela (estilo Waze/Google Maps) com o
  /// que precisa de ação — calcular a rota, ver erro, ver a ordem das
  /// paradas — que o usuário pode arrastar pra cima pra ver mais, ou
  /// deixar recolhido pra sobrar mais espaço pro mapa.
  Widget _buildPainelInferior(BuildContext context, String uid, List<ParadaMotorista> paradas) {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.12,
      maxChildSize: 0.75,
      builder: (context, controlador) {
        return Container(
          decoration: BoxDecoration(
            color: AppCores.fundo(context),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: ListView(
            controller: controlador,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppCores.borda(context), borderRadius: BorderRadius.circular(4)),
                ),
              ),
              if (paradas.isEmpty)
                _buildAviso(context, 'Nenhuma criança no período "$_periodo" ainda.')
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${paradas.length} parada(s) nesse período',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                    ),
                    if (_rota != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _rota = null;
                          _erro = null;
                          _primeiroEnquadramentoFeito = false;
                        }),
                        child: const Text('Recalcular', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_rota == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculando ? null : () => _calcularRota(paradas),
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
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppCores.textoSecundario(context)),
                      const SizedBox(width: 4),
                      Text(
                        '${_rota!.trajetoReal ? '' : '~'}${_rota!.duracao.inMinutes} min',
                        style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.route, size: 14, color: AppCores.textoSecundario(context)),
                      const SizedBox(width: 4),
                      Text(
                        '${_rota!.trajetoReal ? '' : '~'}${_rota!.distanciaKm.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                      ),
                    ],
                  ),
                if (_erro != null) ...[
                  const SizedBox(height: 10),
                  _buildAviso(context, _erro!, cor: Colors.red),
                ],
                if (_rota != null && !_rota!.trajetoReal) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Sem conexão com o traçado de ruas agora — linha reta entre os pontos. A ordem das paradas continua real.',
                    style: TextStyle(fontSize: 10.5, color: AppCores.textoSecundario(context), fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 14),
                if (_rota != null)
                  for (var i = 0; i < _rota!.ordemParadas.length; i++)
                    _buildLinhaParadaOtimizada(context, numero: i + 1, label: _rota!.ordemParadas[i].label)
                else
                  _buildListaSimples(context, paradas),
              ],
            ],
          ),
        );
      },
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
                Text(parada.filhosNomes.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(parada.responsavelNome, style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context))),
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
