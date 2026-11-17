import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'firestore_service.dart';

class LocalizacaoService {
  LocalizacaoService._();
  static final LocalizacaoService instance = LocalizacaoService._();

  // Atualização por tempo fixo (não por distância percorrida) — o responsável
  // vê a posição do motorista renovar a cada 5 segundos, mesmo parado no
  // trânsito, em vez de só quando ele anda 15 metros.
  static const _intervaloAtualizacao = Duration(seconds: 5);

  Timer? _timer;
  String? _motoristaUidAtivo;

  bool get emAndamento => _timer != null;

  Future<String?> iniciarCorrida(String motoristaUid) async {

    if (_timer != null && _motoristaUidAtivo != motoristaUid) {
      await finalizarCorrida(_motoristaUidAtivo!);
    }
    if (_timer != null) return null;

    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return 'Ative o serviço de localização do dispositivo.';

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
      return 'Permissão de localização negada.';
    }

    try {
      await _atualizarPosicao(motoristaUid);
    } catch (e) {
      return 'Não foi possível obter sua localização: $e';
    }

    _motoristaUidAtivo = motoristaUid;
    _timer = Timer.periodic(_intervaloAtualizacao, (_) => _atualizarPosicao(motoristaUid));

    return null;
  }

  Future<void> _atualizarPosicao(String motoristaUid) async {
    final posicao = await Geolocator.getCurrentPosition();
    await FirestoreService.instance.atualizarLocalizacaoAtiva(
      motoristaUid,
      lat: posicao.latitude,
      lng: posicao.longitude,
      emRota: true,
    );
  }

  Future<void> finalizarCorrida(String motoristaUid) async {
    _timer?.cancel();
    _timer = null;
    _motoristaUidAtivo = null;
    await FirestoreService.instance.pararLocalizacaoAtiva(motoristaUid);
  }

  void pararSeContaDiferente(String? uidLogado) {
    final uidAtivo = _motoristaUidAtivo;
    if (uidAtivo == null || uidAtivo == uidLogado) return;

    _timer?.cancel();
    _timer = null;
    _motoristaUidAtivo = null;
    FirestoreService.instance.pararLocalizacaoAtiva(uidAtivo).catchError((_) {});
  }
}
