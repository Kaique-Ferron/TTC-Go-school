import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/auth_service.dart';

void main() {
  group('AuthService.descreverErro', () {
    test('traduz user-not-found', () {
      final erro = FirebaseAuthException(code: 'user-not-found');
      expect(AuthService.descreverErro(erro), 'Nenhuma conta encontrada para este e-mail.');
    });

    test('traduz wrong-password e invalid-credential para a mesma mensagem', () {
      final wrongPassword = FirebaseAuthException(code: 'wrong-password');
      final invalidCredential = FirebaseAuthException(code: 'invalid-credential');
      expect(AuthService.descreverErro(wrongPassword), 'E-mail ou senha incorretos.');
      expect(AuthService.descreverErro(invalidCredential), 'E-mail ou senha incorretos.');
    });

    test('traduz email-already-in-use', () {
      final erro = FirebaseAuthException(code: 'email-already-in-use');
      expect(AuthService.descreverErro(erro), 'Já existe uma conta com este e-mail.');
    });

    test('traduz weak-password', () {
      final erro = FirebaseAuthException(code: 'weak-password');
      expect(AuthService.descreverErro(erro), 'A senha deve ter pelo menos 6 caracteres.');
    });

    test('usa a mensagem original do Firebase para códigos desconhecidos', () {
      final erro = FirebaseAuthException(code: 'algum-codigo-novo', message: 'mensagem original');
      expect(AuthService.descreverErro(erro), 'mensagem original');
    });

    test('usa mensagem genérica quando o código é desconhecido e não há message', () {
      final erro = FirebaseAuthException(code: 'algum-codigo-novo');
      expect(AuthService.descreverErro(erro), 'Ocorreu um erro. Tente novamente.');
    });

    test('usa mensagem genérica para exceções que não são do Firebase', () {
      expect(AuthService.descreverErro(Exception('erro qualquer')), 'Ocorreu um erro. Tente novamente.');
    });
  });
}
