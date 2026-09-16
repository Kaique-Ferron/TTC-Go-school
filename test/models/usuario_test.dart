import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/usuario.dart';

void main() {
  group('Usuario', () {
    test('toMap/fromMap fazem round-trip sem perder dados', () {
      const usuario = Usuario(
        nome: 'Marcos Silva',
        email: 'marcos@teste.com',
        telefone: '(11) 98765-4321',
        cpf: '12345678900',
        perfil: 'Responsável',
        cep: '01310-100',
        rua: 'Av. Paulista',
        numero: '1000',
        bairro: 'Bela Vista',
      );

      final reconstruido = Usuario.fromMap(usuario.toMap());

      expect(reconstruido.nome, usuario.nome);
      expect(reconstruido.email, usuario.email);
      expect(reconstruido.telefone, usuario.telefone);
      expect(reconstruido.cpf, usuario.cpf);
      expect(reconstruido.perfil, usuario.perfil);
      expect(reconstruido.cep, usuario.cep);
      expect(reconstruido.rua, usuario.rua);
      expect(reconstruido.numero, usuario.numero);
      expect(reconstruido.bairro, usuario.bairro);
    });

    test('fromMap preenche com valores padrão quando faltam campos', () {
      final usuario = Usuario.fromMap({'nome': 'João'});

      expect(usuario.nome, 'João');
      expect(usuario.email, '');
      expect(usuario.perfil, 'Responsável');
      expect(usuario.cnh, '');
    });

    test('cpf e telefone são preservados como String (sem perder zeros à esquerda)', () {
      const usuario = Usuario(
        nome: 'Teste',
        email: 'a@a.com',
        telefone: '011987654321',
        cpf: '01234567890',
        perfil: 'Responsável',
      );

      final mapa = usuario.toMap();

      expect(mapa['cpf'], '01234567890');
      expect(mapa['telefone'], '011987654321');
    });
  });
}
