import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/contato_chat.dart';
import '../models/conversa_model.dart';
import '../models/filho.dart';
import '../models/mensagem_model.dart';
import '../models/mensalidade_model.dart';
import '../models/motorista_model.dart';
import '../models/usuario.dart';

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

  CollectionReference<Map<String, dynamic>> _filhos(String uid) =>
      _usuarios.doc(uid).collection('filhos');

  Future<void> salvarUsuario(String uid, Usuario usuario) {
    return _usuarios.doc(uid).set({
      ...usuario.toMap(),
      'uid': uid,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza campos específicos do usuário sem sobrescrever o documento inteiro.
  Future<void> atualizarUsuario(String uid, Map<String, dynamic> dados) {
    return _usuarios.doc(uid).update(dados);
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

  /// Motoristas reais cadastrados no app (usuarios com tipoPerfil = 'motorista'),
  /// exibidos na aba "Serviços" da landpage.
  Stream<List<Motorista>> motoristasStream() {
    return _usuarios.where('tipoPerfil', isEqualTo: 'motorista').snapshots().map(
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
    await ref.update({
      'ultimaMensagem': texto,
      'ultimaMensagemEm': FieldValue.serverTimestamp(),
    });
  }
}
