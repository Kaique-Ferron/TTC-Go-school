import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filho.dart';
import '../models/mensalidade_model.dart';
import '../models/motorista_model.dart';
import '../models/usuario.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}
