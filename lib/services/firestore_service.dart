import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/filho.dart';
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
    return _usuarios.doc(uid).set(usuario.toMap());
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
}
