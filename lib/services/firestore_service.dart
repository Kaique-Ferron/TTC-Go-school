import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/avaliacao_model.dart';
import '../models/contato_chat.dart';
import '../models/conversa_model.dart';
import '../models/crianca_rota.dart';
import '../models/escola_rota.dart';
import '../models/filho.dart';
import '../models/localizacao_motorista.dart';
import '../models/mensagem_model.dart';
import '../models/mensalidade_model.dart';
import '../models/motorista_model.dart';
import '../models/parada_motorista.dart';
import '../models/usuario.dart';
import 'notification_service.dart';

class FirestoreService {
  FirestoreService._(this._db);
  static final FirestoreService instance = FirestoreService._(FirebaseFirestore.instance);

  @visibleForTesting
  factory FirestoreService.comInstancia(FirebaseFirestore db) => FirestoreService._(db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');

  CollectionReference<Map<String, dynamic>> get _motoristasPublico =>
      _db.collection('motoristas_publico');

  CollectionReference<Map<String, dynamic>> _filhos(String uid) =>
      _usuarios.doc(uid).collection('filhos');

  Future<void> salvarUsuario(String uid, Usuario usuario) async {
    await _usuarios.doc(uid).set({
      ...usuario.toMap(),
      'uid': uid,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    if (usuario.tipoPerfil == 'motorista') {
      await _sincronizarPerfilPublico(uid, usuario.toMap());
    }
  }

  Future<void> atualizarUsuario(String uid, Map<String, dynamic> dados) async {
    await _usuarios.doc(uid).update(dados);
    final atual = (await _usuarios.doc(uid).get()).data();
    if (atual != null && atual['tipoPerfil'] == 'motorista') {
      await _sincronizarPerfilPublico(uid, atual);
    }
  }

  Future<void> _sincronizarPerfilPublico(String uid, Map<String, dynamic> dados) {
    return _motoristasPublico.doc(uid).set({
      'uid': uid,
      'nome': dados['nome'] ?? '',
      'veiculo': dados['veiculo'] ?? '',
      'placa': dados['placa'] ?? '',
      'licenca': dados['licenca'] ?? '',
      'fotoPerfil': dados['fotoPerfil'] ?? '',
    });
  }

  Future<void> salvarPreferencias(String uid, {required String tema, required String tamanhoFonte}) {
    return atualizarUsuario(uid, {'tema': tema, 'tamanhoFonte': tamanhoFonte});
  }

  Stream<Usuario?> usuarioStream(String uid) {
    return _usuarios.doc(uid).snapshots().map((doc) {
      final dados = doc.data();
      return dados == null ? null : Usuario.fromMap(dados);
    });
  }

  Stream<List<Filho>> filhosStream(String uid) {
    return _filhos(uid).orderBy('nome').snapshots().map(
          (snap) => snap.docs.map((d) => Filho.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> salvarFilho(String uid, Filho filho) {
    final ref = filho.id == null ? _filhos(uid).doc() : _filhos(uid).doc(filho.id);
    return ref.set(filho.toMap());
  }

  Future<void> excluirFilho(String uid, String filhoId) {
    return _filhos(uid).doc(filhoId).delete();
  }

  Stream<List<Motorista>> motoristasStream() {
    return _motoristasPublico.snapshots().map(
          (snap) => snap.docs.map((d) => Motorista.fromUsuarioMap(d.data())).toList(),
        );
  }

  CollectionReference<Map<String, dynamic>> _mensalidades(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('mensalidades');

  Stream<List<Mensalidade>> mensalidadesStream(String motoristaUid) {
    return _mensalidades(motoristaUid).orderBy('data', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Mensalidade.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> semearMensalidadesMock(String motoristaUid, List<Mensalidade> mensalidades) async {
    final lote = _db.batch();
    for (var i = 0; i < mensalidades.length; i++) {
      final ref = _mensalidades(motoristaUid).doc('mock_${i + 1}');
      lote.set(ref, mensalidades[i].toMap());
    }
    await lote.commit();
  }

  Future<void> registrarContratacao(String responsavelUid, Map<String, dynamic> dados) {
    // Id do documento = motoristaUid (determinístico, igual ao padrão já
    // usado em responsaveis_ativos) — é o que permite a regra do Firestore
    // confirmar com exists()/get() que existe mesmo uma contratação Ativo
    // antes de liberar localização ao vivo e avaliação (ver firestore.rules).
    // Contratar o mesmo motorista de novo atualiza esse registro único, em
    // vez de criar um documento separado — a própria tela de contratação já
    // trata "já é o motorista atual" como uma coisa só.
    return _usuarios.doc(responsavelUid).collection('contratacoes').doc(dados['motoristaUid'] as String).set(dados);
  }

  Future<void> sincronizarLocalizacaoNasContratacoes(
    String responsavelUid, {
    required double lat,
    required double lng,
    String? endereco,
  }) async {
    final contratacoesAtivas = await _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .get();
    if (contratacoesAtivas.docs.isEmpty) return;

    final lote = _db.batch();
    for (final doc in contratacoesAtivas.docs) {
      lote.update(doc.reference, {
        'responsavelLat': lat,
        'responsavelLng': lng,
        if (endereco != null) 'responsavelEndereco': endereco,
      });
    }
    await lote.commit();
  }

  // Lê, pra cada filhoId, a escola marcada nele agora (não o que já estava
  // gravado na contratação) e monta a lista de escolas distintas — é assim
  // que uma contratação com filhos em escolas diferentes guarda todas, não
  // só a primeira.
  Future<List<EscolaRota>> _escolasDosFilhos(String responsavelUid, List<dynamic> filhosIds) async {
    final escolas = <String, EscolaRota>{};
    for (final filhoId in filhosIds) {
      final doc = await _filhos(responsavelUid).doc(filhoId as String).get();
      final dados = doc.data();
      final lat = (dados?['escolaLat'] as num?)?.toDouble();
      final lng = (dados?['escolaLng'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final nome = (dados?['escola'] as String?) ?? '';
      escolas[nome.isNotEmpty ? nome : '$lat,$lng'] = EscolaRota(nome: nome, lat: lat, lng: lng);
    }
    return escolas.values.toList();
  }

  Future<void> sincronizarEscolaDoFilhoNasContratacoes(
    String responsavelUid,
    String filhoId, {
    required String escolaNome,
    required double lat,
    required double lng,
  }) async {
    final contratacoesAtivas = await _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .where('filhosIds', arrayContains: filhoId)
        .get();
    if (contratacoesAtivas.docs.isEmpty) return;

    for (final doc in contratacoesAtivas.docs) {
      final filhosIds = (doc.data()['filhosIds'] as List?) ?? const [];
      final escolas = await _escolasDosFilhos(responsavelUid, filhosIds);
      await doc.reference.update({
        'escolas': escolas.map((e) => e.toMap()).toList(),
        // Campos singulares mantidos só por compatibilidade com quem ainda
        // os lê (contratações antigas, telas que mostram uma escola só).
        'escolaNome': escolas.isNotEmpty ? escolas.first.nome : '',
        'escolaLat': escolas.isNotEmpty ? escolas.first.lat : null,
        'escolaLng': escolas.isNotEmpty ? escolas.first.lng : null,
      });
    }
  }

  final Set<String> _escolaSincronizada = {};

  Future<void> autoSincronizarEscolasNasContratacoes(String responsavelUid, List<Filho> filhos) async {
    if (_escolaSincronizada.contains(responsavelUid)) return;
    for (final filho in filhos) {
      if (filho.id == null || !filho.temLocalizacaoEscola) continue;
      await sincronizarEscolaDoFilhoNasContratacoes(
        responsavelUid,
        filho.id!,
        escolaNome: filho.escola,
        lat: filho.escolaLat!,
        lng: filho.escolaLng!,
      );
    }
    _escolaSincronizada.add(responsavelUid);
  }

  final Set<String> _localizacaoSincronizada = {};

  Future<void> autoSincronizarLocalizacaoNasContratacoes(
    String responsavelUid, {
    required double lat,
    required double lng,
    String? endereco,
  }) async {
    if (_localizacaoSincronizada.contains(responsavelUid)) return;

    await sincronizarLocalizacaoNasContratacoes(responsavelUid, lat: lat, lng: lng, endereco: endereco);
    _localizacaoSincronizada.add(responsavelUid);
  }

  Stream<bool> temContratacaoAtivaStream(String responsavelUid) {
    return _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  Stream<Map<String, dynamic>?> contratacaoAtivaStream(String responsavelUid) {
    return _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data());
  }

  Stream<List<ContatoChat>> meusMotoristasContratadosStream(String responsavelUid) {
    return _usuarios.doc(responsavelUid).collection('contratacoes').snapshots().map((snap) {
      final vistos = <String>{};
      final lista = <ContatoChat>[];
      for (final doc in snap.docs) {
        final dados = doc.data();
        final uid = dados['motoristaUid'] as String?;
        if (uid == null || uid.isEmpty || !vistos.add(uid)) continue;
        lista.add(ContatoChat(uid: uid, nome: (dados['motoristaNome'] as String?) ?? ''));
      }
      return lista;
    });
  }

  Stream<List<ContatoChat>> meusResponsaveisStream(String motoristaUid) {
    return _db
        .collectionGroup('contratacoes')
        .where('motoristaUid', isEqualTo: motoristaUid)
        .snapshots()
        .map((snap) {
      final vistos = <String>{};
      final lista = <ContatoChat>[];
      for (final doc in snap.docs) {
        final responsavelUid = doc.reference.parent.parent?.id;
        if (responsavelUid == null || !vistos.add(responsavelUid)) continue;
        lista.add(ContatoChat(uid: responsavelUid, nome: (doc.data()['responsavelNome'] as String?) ?? ''));
      }
      return lista;
    });
  }

  // Mesma consulta (collection group por motoristaUid) já usada acima — sem
  // orderBy de propósito, pra não exigir um índice composto novo. A
  // ordenação por data é feita no cliente, em quem consome esse stream.
  Stream<List<Map<String, dynamic>>> contratacoesRecebidasStream(String motoristaUid) {
    return _db
        .collectionGroup('contratacoes')
        .where('motoristaUid', isEqualTo: motoristaUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  CollectionReference<Map<String, dynamic>> _chamadas(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('chamadas');

  String chamadaIdPara(DateTime data, String periodo) {
    final d =
        '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    return '${d}_$periodo';
  }

  Stream<List<CriancaRota>> criancasDaRotaStream(String motoristaUid) {
    return _db.collectionGroup('contratacoes').where('motoristaUid', isEqualTo: motoristaUid).snapshots().map((
      snap,
    ) {
      final lista = <CriancaRota>[];
      for (final doc in snap.docs) {
        final dados = doc.data();
        if (dados['status'] != 'Ativo') continue;
        final responsavelUid = doc.reference.parent.parent?.id;
        if (responsavelUid == null) continue;
        final responsavelNome = (dados['responsavelNome'] as String?) ?? '';
        final periodo = (dados['periodo'] as String?) ?? '';
        final filhosIds = (dados['filhosIds'] as List?)?.cast<String>() ?? [];
        final filhosNomes = (dados['filhosNomes'] as List?)?.cast<String>() ?? [];
        for (var i = 0; i < filhosIds.length; i++) {
          lista.add(
            CriancaRota(
              filhoId: filhosIds[i],
              nome: i < filhosNomes.length ? filhosNomes[i] : 'Criança',
              periodo: periodo,
              responsavelUid: responsavelUid,
              responsavelNome: responsavelNome,
            ),
          );
        }
      }
      return lista;
    });
  }

  Stream<List<ParadaMotorista>> paradasRotaStream(String motoristaUid) {
    return _db.collectionGroup('contratacoes').where('motoristaUid', isEqualTo: motoristaUid).snapshots().map((
      snap,
    ) {

      final paradasPorChave = <String, ParadaMotorista>{};
      for (final doc in snap.docs) {
        final dados = doc.data();
        if (dados['status'] != 'Ativo') continue;
        final responsavelUid = doc.reference.parent.parent?.id;
        if (responsavelUid == null) continue;

        final periodo = (dados['periodo'] as String?) ?? '';
        final chave = '${responsavelUid}_$periodo';
        final filhosNomes = (dados['filhosNomes'] as List?)?.cast<String>() ?? [];
        final existente = paradasPorChave[chave];

        // Suporta tanto o campo novo ("escolas", lista) quanto contratações
        // antigas que só tinham o campo singular (escolaNome/Lat/Lng).
        final escolasDoc = (dados['escolas'] as List?)
                ?.map((e) => EscolaRota.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <EscolaRota>[];
        final escolaLatAntiga = (dados['escolaLat'] as num?)?.toDouble();
        final escolaLngAntiga = (dados['escolaLng'] as num?)?.toDouble();
        final escolasDesteDoc = escolasDoc.isNotEmpty
            ? escolasDoc
            : (escolaLatAntiga != null && escolaLngAntiga != null)
                ? [EscolaRota(nome: (dados['escolaNome'] as String?) ?? '', lat: escolaLatAntiga, lng: escolaLngAntiga)]
                : const <EscolaRota>[];

        // Une com o que já tinha pra essa parada (vários responsáveis do
        // mesmo período podem ir pra escolas diferentes) — dedup por nome.
        final escolasUnidas = <String, EscolaRota>{
          for (final e in existente?.escolas ?? const <EscolaRota>[]) e.nome: e,
          for (final e in escolasDesteDoc) e.nome: e,
        };

        paradasPorChave[chave] = ParadaMotorista(
          responsavelUid: responsavelUid,
          responsavelNome: (dados['responsavelNome'] as String?) ?? '',
          endereco: (dados['responsavelEndereco'] as String?) ?? '',
          lat: (dados['responsavelLat'] as num?)?.toDouble(),
          lng: (dados['responsavelLng'] as num?)?.toDouble(),
          periodo: periodo,
          filhosNomes: [...?existente?.filhosNomes, ...filhosNomes],
          escolas: escolasUnidas.values.toList(),
        );
      }
      return paradasPorChave.values.toList();
    });
  }

  DocumentReference<Map<String, dynamic>> _localizacaoAtiva(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('localizacao_ativa').doc('atual');

  final Set<String> _responsaveisAtivosConfirmados = {};

  Future<void> registrarResponsavelAtivo(String motoristaUid, String responsavelUid) async {
    final chave = '${motoristaUid}_$responsavelUid';
    if (_responsaveisAtivosConfirmados.contains(chave)) return;

    await _usuarios
        .doc(motoristaUid)
        .collection('responsaveis_ativos')
        .doc(responsavelUid)
        .set({'ativo': true});
    _responsaveisAtivosConfirmados.add(chave);
  }

  Future<void> atualizarLocalizacaoAtiva(
    String motoristaUid, {
    required double lat,
    required double lng,
    required bool emRota,
  }) {
    return _localizacaoAtiva(motoristaUid).set({
      'lat': lat,
      'lng': lng,
      'emRota': emRota,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pararLocalizacaoAtiva(String motoristaUid) {
    return _localizacaoAtiva(motoristaUid).set({'emRota': false}, SetOptions(merge: true));
  }

  Stream<LocalizacaoMotorista?> localizacaoAtivaStream(String motoristaUid) {
    return _localizacaoAtiva(motoristaUid).snapshots().map((doc) {
      final dados = doc.data();
      return dados == null ? null : LocalizacaoMotorista.fromMap(dados);
    });
  }

  Stream<Map<String, dynamic>?> chamadaStream(String motoristaUid, String chamadaId) {
    return _chamadas(motoristaUid).doc(chamadaId).snapshots().map((doc) => doc.data());
  }

  Future<void> marcarPresenca({
    required String motoristaUid,
    required String motoristaNome,
    required String chamadaId,
    required String periodo,
    required CriancaRota crianca,
    required bool presente,
  }) async {
    await _chamadas(motoristaUid).doc(chamadaId).set({
      'periodo': periodo,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'criancas': {
        crianca.filhoId: {
          'nome': crianca.nome,
          'responsavelUid': crianca.responsavelUid,
          'presente': presente,
          'confirmadoEm': FieldValue.serverTimestamp(),
        },
      },
    }, SetOptions(merge: true));

    final conversaId = await obterOuCriarConversa(
      meuUid: motoristaUid,
      meuNome: motoristaNome,
      outroUid: crianca.responsavelUid,
      outroNome: crianca.responsavelNome,
    );
    final agora = DateTime.now();
    final hora = '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';
    final texto = presente
        ? '✅ ${crianca.nome} embarcou na van às $hora.'
        : '⚠️ ${crianca.nome} foi marcado(a) como ausente na chamada de hoje.';
    await enviarMensagem(conversaId: conversaId, remetenteUid: motoristaUid, texto: texto);
  }

  CollectionReference<Map<String, dynamic>> get _conversas => _db.collection('conversas');

  String conversaIdPara(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> obterOuCriarConversa({
    required String meuUid,
    required String meuNome,
    required String outroUid,
    required String outroNome,
  }) async {
    final id = conversaIdPara(meuUid, outroUid);
    final ref = _conversas.doc(id);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'participantes': [meuUid, outroUid],
        'participantesNomes': {meuUid: meuNome, outroUid: outroNome},
        'ultimaMensagem': '',
        'ultimaMensagemEm': FieldValue.serverTimestamp(),
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }

    final meuPushId = NotificationService.subscriptionIdAtual;
    if (meuPushId != null && meuPushId.isNotEmpty) {
      await ref.set({
        'participantesPushIds': {meuUid: meuPushId},
      }, SetOptions(merge: true));
    }

    return id;
  }

  Stream<List<Conversa>> conversasStream(String uid) {
    return _conversas.where('participantes', arrayContains: uid).snapshots().map((snap) {
      final conversas = snap.docs.map((d) => Conversa.fromMap(d.id, d.data())).toList();
      conversas.sort((a, b) {
        if (a.ultimaMensagemEm == null) return 1;
        if (b.ultimaMensagemEm == null) return -1;
        return b.ultimaMensagemEm!.compareTo(a.ultimaMensagemEm!);
      });
      return conversas;
    });
  }

  Stream<List<Mensagem>> mensagensStream(String conversaId) {
    return _conversas.doc(conversaId).collection('mensagens').orderBy('enviadaEm').snapshots().map(
          (snap) => snap.docs.map((d) => Mensagem.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> enviarMensagem({
    required String conversaId,
    required String remetenteUid,
    required String texto,
  }) async {
    final ref = _conversas.doc(conversaId);
    await ref.collection('mensagens').add({
      'remetenteUid': remetenteUid,
      'texto': texto,
      'enviadaEm': FieldValue.serverTimestamp(),
    });
    final dadosConversa = {
      'ultimaMensagem': texto,
      'ultimaMensagemEm': FieldValue.serverTimestamp(),
    };
    await ref.update(dadosConversa);
    await _notificarNovaMensagem(ref: ref, remetenteUid: remetenteUid, texto: texto);
  }

  Future<void> _notificarNovaMensagem({
    required DocumentReference<Map<String, dynamic>> ref,
    required String remetenteUid,
    required String texto,
  }) async {
    try {
      final dados = (await ref.get()).data();
      if (dados == null) return;

      final participantes = (dados['participantes'] as List?)?.cast<String>() ?? [];
      final outroUid = participantes.firstWhere(
        (uid) => uid != remetenteUid,
        orElse: () => '',
      );
      if (outroUid.isEmpty) return;

      final pushIds = dados['participantesPushIds'] as Map<String, dynamic>?;
      final subscriptionId = pushIds?[outroUid] as String?;
      if (subscriptionId == null || subscriptionId.isEmpty) return;

      final nomes = dados['participantesNomes'] as Map<String, dynamic>?;
      final remetenteNome = (nomes?[remetenteUid] as String?) ?? 'Nova mensagem';

      await NotificationService.enviarPush(
        subscriptionId: subscriptionId,
        titulo: remetenteNome,
        mensagem: texto,
      );
    } catch (_) {

    }
  }

  CollectionReference<Map<String, dynamic>> _avaliacoes(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('avaliacoes');

  Stream<List<Avaliacao>> avaliacoesStream(String motoristaUid) {
    return _avaliacoes(motoristaUid).orderBy('criadoEm', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Avaliacao.fromMap(d.data())).toList(),
        );
  }

  Future<void> enviarAvaliacao({
    required String motoristaUid,
    required String responsavelUid,
    required String responsavelNome,
    required int nota,
    required String comentario,
  }) {
    final avaliacao = Avaliacao(
      responsavelUid: responsavelUid,
      responsavelNome: responsavelNome,
      nota: nota,
      comentario: comentario,
      criadoEm: DateTime.now(),
    );
    return _avaliacoes(motoristaUid).doc(responsavelUid).set(avaliacao.toMap());
  }
}
