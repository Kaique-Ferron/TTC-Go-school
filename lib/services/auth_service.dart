import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emite true/false conforme o usuário está autenticado ou não.
  Stream<bool> get logado =>
      _auth.authStateChanges().map((usuario) => usuario != null);

  String? get uidAtual => _auth.currentUser?.uid;
  String? get emailAtual => _auth.currentUser?.email;

  /// Cria a conta no Firebase Auth e retorna o uid do novo usuário.
  Future<String> cadastrar({required String email, required String senha}) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    return credencial.user!.uid;
  }

  Future<void> entrar({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> recuperarSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  /// Converte erros do Firebase em mensagens amigáveis para exibir ao usuário.
  /// Estático: não depende de _auth, então pode ser testado sem inicializar o Firebase.
  static String descreverErro(Object erro) {
    if (erro is FirebaseAuthException) {
      switch (erro.code) {
        case 'user-not-found':
          return 'Nenhuma conta encontrada para este e-mail.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'email-already-in-use':
          return 'Já existe uma conta com este e-mail.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'weak-password':
          return 'A senha deve ter pelo menos 6 caracteres.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet.';
        default:
          return erro.message ?? 'Ocorreu um erro. Tente novamente.';
      }
    }
    return 'Ocorreu um erro. Tente novamente.';
  }
}
