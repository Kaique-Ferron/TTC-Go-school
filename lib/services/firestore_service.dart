import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/avaliacao_model.dart';
import '../models/contato_chat.dart';
import '../models/conversa_model.dart';
import '../models/crianca_rota.dart';
import '../models/filho.dart';
import '../models/mensagem_model.dart';
import '../models/mensalidade_model.dart';
import '../models/motorista_model.dart';
import '../models/parada_motorista.dart';
import '../models/usuario.dart';
import 'notification_service.dart';

class FirestoreService {
  FirestoreService._(this._db);
  static final FirestoreService instance = FirestoreService._(FirebaseFirestore.instance);

  /// Construtor usado em testes de widget, pra injetar um FirebaseFirestore
  /// fake (ex.: FakeFirebaseFirestore do pacote fake_cloud_firestore) em vez
  /// do singleton real.
  @visibleForTesting
  factory FirestoreService.comInstancia(FirebaseFirestore db) => FirestoreService._(db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');

  // Subconjunto público do perfil do Motorista (nome/veículo/placa/
  // licença/foto) — ver comentário em salvarUsuario sobre por que isso
  // existe separado do documento completo em usuarios/{uid}.
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

  /// Atualiza campos específicos do usuário sem sobrescrever o documento inteiro.
  ///
  /// Se o usuário for Motorista, também espelha os campos públicos
  /// (nome/veículo/placa/licença/foto) em motoristas_publico/{uid} — essa
  /// cópia é o que a busca de motoristas (motoristasStream) lê, em vez do
  /// documento completo de usuarios/{uid}. Antes, qualquer responsável
  /// logado conseguia ler o documento INTEIRO de um motorista (regra do
  /// Firestore não filtra campo, só documento), o que expunha cpf/cnh/
  /// endereço junto com os dados exibidos na tela. Ver firestore.rules.
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

  /// Preferências de aparência (tema e tamanho da fonte) — ver
  /// [PreferenciasProvider], que aplica esses valores no MaterialApp inteiro.
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

  /// Motoristas reais cadastrados no app, exibidos na aba "Serviços" da
  /// landpage — lê o perfil PÚBLICO (motoristas_publico/{uid}), não o
  /// documento completo em usuarios/{uid} (que tem cpf/cnh/endereço).
  Stream<List<Motorista>> motoristasStream() {
    return _motoristasPublico.snapshots().map(
          (snap) => snap.docs.map((d) => Motorista.fromUsuarioMap(d.data())).toList(),
        );
  }

  // ===== Mensalidades (Finanças do Motorista) =====
  // Caminho: usuarios/{motoristaUid}/mensalidades/{mensalidadeId}
  // Ver firestore/MIGRATIONS.md para o schema completo e como semear os dados.

  CollectionReference<Map<String, dynamic>> _mensalidades(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('mensalidades');

  Stream<List<Mensalidade>> mensalidadesStream(String motoristaUid) {
    return _mensalidades(motoristaUid).orderBy('data', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Mensalidade.fromMap(d.id, d.data())).toList(),
        );
  }

  /// "Migração"/seed: grava os dados mockados de mensalidade como documentos
  /// reais no Firestore do motorista logado. Usa IDs fixos (mock_1..mock_5)
  /// para ser idempotente — rodar de novo só sobrescreve os mesmos docs, não
  /// duplica. Chamado pelo botão "Carregar dados de exemplo" na tela de
  /// Finanças quando a subcoleção ainda está vazia.
  Future<void> semearMensalidadesMock(String motoristaUid, List<Mensalidade> mensalidades) async {
    final lote = _db.batch();
    for (var i = 0; i < mensalidades.length; i++) {
      final ref = _mensalidades(motoristaUid).doc('mock_${i + 1}');
      lote.set(ref, mensalidades[i].toMap());
    }
    await lote.commit();
  }

  // ===== Contratação (Responsável contrata um Motorista) =====
  // Caminho: usuarios/{responsavelUid}/contratacoes/{contratacaoId}
  // Ver firestore/MIGRATIONS.md para o schema completo.

  Future<void> registrarContratacao(String responsavelUid, Map<String, dynamic> dados) {
    return _usuarios.doc(responsavelUid).collection('contratacoes').add(dados);
  }

  /// Se o Responsável já tem algum motorista contratado — usado pra decidir
  /// qual tela de início mostrar (landpage de busca ou painel de
  /// acompanhamento). Reativo: se ele contratar ou (no futuro) cancelar,
  /// a tela de início muda sozinha, sem precisar deslogar/logar de novo.
  Stream<bool> temContratacaoAtivaStream(String responsavelUid) {
    return _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// Dados completos da contratação ativa do Responsável (o motorista que
  /// ele selecionou agora) — usado na seção "Motorista selecionado" da tela
  /// de Perfil. Retorna null se não houver nenhuma contratação ativa.
  Stream<Map<String, dynamic>?> contratacaoAtivaStream(String responsavelUid) {
    return _usuarios
        .doc(responsavelUid)
        .collection('contratacoes')
        .where('status', isEqualTo: 'Ativo')
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data());
  }

  /// Motoristas que o Responsável já contratou — vira a lista de contatos pra
  /// começar uma conversa nova sem passar pela aba Serviços de novo.
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

  /// Responsáveis que já contrataram esse motorista — via collectionGroup,
  /// já que a contratação é gravada do lado do Responsável
  /// (usuarios/{responsavelUid}/contratacoes). Precisa de um índice de
  /// collection group pra 'motoristaUid' no Firestore (o próprio erro no
  /// console, na primeira vez que rodar, traz o link pra criar).
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

  // ===== Chamada (Motorista confirma presença das crianças na van) =====
  // Caminho: usuarios/{motoristaUid}/chamadas/{chamadaId}
  // chamadaId = '{yyyy-MM-dd}_{periodo}' — idempotente, uma chamada por
  // dia/período (marcar de novo no mesmo dia atualiza, não duplica).
  // Ver firestore/MIGRATIONS.md para o schema completo.

  CollectionReference<Map<String, dynamic>> _chamadas(String motoristaUid) =>
      _usuarios.doc(motoristaUid).collection('chamadas');

  String chamadaIdPara(DateTime data, String periodo) {
    final d =
        '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    return '${d}_$periodo';
  }

  /// Todas as crianças nas rotas ativas desse motorista, pra montar a lista
  /// da chamada. Reusa a mesma consulta (e o mesmo índice) de
  /// meusResponsaveisStream; filtra status == 'Ativo' no cliente pra não
  /// precisar de um índice composto novo no collection group.
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

  /// Paradas da rota desse motorista (uma por responsável + período —
  /// pode ter mais de um filho do mesmo responsável na mesma parada),
  /// prontas pra calcular a rota otimizada (ver RotaService). Reusa a
  /// mesma consulta collection group de criancasDaRotaStream/
  /// meusResponsaveisStream. lat/lng/endereco vêm do que foi gravado na
  /// contratação (ver registrarContratacao em tela_contratacao.dart) — é
  /// uma cópia da localização de casa do responsável no momento em que ele
  /// contratou, não ao vivo (se ele mudar o pino depois, não atualiza aqui
  /// sozinho).
  Stream<List<ParadaMotorista>> paradasRotaStream(String motoristaUid) {
    return _db.collectionGroup('contratacoes').where('motoristaUid', isEqualTo: motoristaUid).snapshots().map((
      snap,
    ) {
      // Agrupa por (responsavelUid, período) — se o mesmo responsável tiver
      // mais de uma contratação pro mesmo período (não deveria, mas não
      // custa tolerar), funde os nomes dos filhos numa parada só.
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

        paradasPorChave[chave] = ParadaMotorista(
          responsavelUid: responsavelUid,
          responsavelNome: (dados['responsavelNome'] as String?) ?? '',
          endereco: (dados['responsavelEndereco'] as String?) ?? '',
          lat: (dados['responsavelLat'] as num?)?.toDouble(),
          lng: (dados['responsavelLng'] as num?)?.toDouble(),
          periodo: periodo,
          filhosNomes: [...?existente?.filhosNomes, ...filhosNomes],
        );
      }
      return paradasPorChave.values.toList();
    });
  }

  /// Chamada de um dia/período — mapa filhoId -> {nome, presente, confirmadoEm}.
  /// Null se ainda não foi feita nenhuma marcação nesse dia/período.
  Stream<Map<String, dynamic>?> chamadaStream(String motoristaUid, String chamadaId) {
    return _chamadas(motoristaUid).doc(chamadaId).snapshots().map((doc) => doc.data());
  }

  /// Marca presença/ausência de uma criança na chamada do dia (grava com
  /// merge, então chamar de novo só atualiza aquela criança, sem apagar as
  /// outras já marcadas). Também manda uma mensagem real no chat pro
  /// responsável — reusa a infraestrutura de chat já existente em vez de
  /// criar um sistema de notificação paralelo que mais ninguém leria.
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

  // ===== Chat (conversas entre Responsável e Motorista) =====
  // Caminho: conversas/{conversaId} e conversas/{conversaId}/mensagens/{mensagemId}.
  // Ver firestore/MIGRATIONS.md para o schema completo.

  CollectionReference<Map<String, dynamic>> get _conversas => _db.collection('conversas');

  /// Id determinístico pra dupla (uidA, uidB): sempre os dois uids ordenados
  /// e juntos com "_", então a mesma dupla sempre cai na mesma conversa.
  String conversaIdPara(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Retorna o id da conversa entre os dois usuários, criando o documento
  /// (com os nomes dos participantes) se ainda não existir.
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

    // Espelha meu id de inscrição push nessa conversa (pra o outro
    // participante conseguir me notificar de uma mensagem nova, sem
    // precisar ler meu documento completo de usuarios/{uid}) — atualiza
    // sempre que alguém abre a conversa, então o id tende a ficar fresco.
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

  /// Notifica (push real, via OneSignal) o OUTRO participante da conversa
  /// sobre a mensagem que acabou de ser enviada. Nunca deixa uma falha
  /// aqui travar o envio da mensagem em si — notificação é um extra.
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
      // Ver comentário acima.
    }
  }

  // ===== Avaliações (Responsável avalia o Motorista) =====
  // Caminho: usuarios/{motoristaUid}/avaliacoes/{responsavelUid} — um
  // documento por responsável (o id fixo evita duplicar e deixa o
  // responsável atualizar a própria nota depois). Ver firestore/MIGRATIONS.md.

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
