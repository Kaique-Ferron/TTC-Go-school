import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'firestore_service.dart';

/// Compartilhamento de localização ao vivo do Motorista — liga o GPS do
/// aparelho a usuarios/{motoristaUid}/localizacao_ativa/atual enquanto a
/// corrida estiver iniciada. Sem nenhuma API paga: é só o GPS do próprio
/// celular (geolocator) + Firestore, igual ao app de 99/Uber mostra o
/// entregador pro cliente.
///
/// É um singleton (uma instância pro app inteiro) — por isso guarda qual
/// motoristaUid está sendo compartilhado (`_motoristaUidAtivo`), não só se
/// tem uma assinatura ativa. Sem isso, trocar de conta (deslogar de um
/// Motorista e logar em outro, no mesmo navegador, sem fechar a aba) deixa
/// o GPS continuar atualizando a localização da conta ANTERIOR pra sempre,
/// e a tela "Minhas Rotas" da conta NOVA mostra "corrida em andamento"
/// mesmo sem ela ter apertado nada — ver [pararSeContaDiferente], chamado
/// pelo AuthGate a cada troca de sessão.
class LocalizacaoService {
  LocalizacaoService._();
  static final LocalizacaoService instance = LocalizacaoService._();

  StreamSubscription<Position>? _assinatura;
  String? _motoristaUidAtivo;

  bool get emAndamento => _assinatura != null;

  /// Pede permissão de localização (se ainda não tiver) e começa a
  /// reportar a posição pro Firestore a cada ~15 metros de movimento.
  /// Retorna uma mensagem de erro amigável se não der pra começar, ou null
  /// se deu tudo certo.
  Future<String?> iniciarCorrida(String motoristaUid) async {
    // Defesa extra: se por algum motivo ainda tiver uma corrida de OUTRA
    // conta rodando, para ela antes de começar uma nova.
    if (_assinatura != null && _motoristaUidAtivo != motoristaUid) {
      await finalizarCorrida(_motoristaUidAtivo!);
    }
    if (_assinatura != null) return null; // já em andamento, pra essa mesma conta

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
      final posicaoInicial = await Geolocator.getCurrentPosition();
      await FirestoreService.instance.atualizarLocalizacaoAtiva(
        motoristaUid,
        lat: posicaoInicial.latitude,
        lng: posicaoInicial.longitude,
        emRota: true,
      );
    } catch (e) {
      return 'Não foi possível obter sua localização: $e';
    }

    _motoristaUidAtivo = motoristaUid;
    _assinatura = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15),
    ).listen((posicao) {
      FirestoreService.instance.atualizarLocalizacaoAtiva(
        motoristaUid,
        lat: posicao.latitude,
        lng: posicao.longitude,
        emRota: true,
      );
    });

    return null;
  }

  Future<void> finalizarCorrida(String motoristaUid) async {
    await _assinatura?.cancel();
    _assinatura = null;
    _motoristaUidAtivo = null;
    await FirestoreService.instance.pararLocalizacaoAtiva(motoristaUid);
  }

  /// Chamado pelo AuthGate toda vez que a sessão muda (login, logout, troca
  /// de conta). Se existe uma corrida ativa que NÃO é da conta atualmente
  /// logada no aparelho, para o compartilhamento imediatamente — ninguém
  /// decidiu continuar aquela corrida, só sobrou da sessão anterior.
  void pararSeContaDiferente(String? uidLogado) {
    final uidAtivo = _motoristaUidAtivo;
    if (uidAtivo == null || uidAtivo == uidLogado) return;

    _assinatura?.cancel();
    _assinatura = null;
    _motoristaUidAtivo = null;
    FirestoreService.instance.pararLocalizacaoAtiva(uidAtivo).catchError((_) {});
  }
}
