import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/filho.dart';

void main() {
  group('Filho', () {
    test('toMap/fromMap fazem round-trip sem perder dados', () {
      const filho = Filho(
        id: 'abc123',
        nome: 'João Silva',
        idadeEAno: '9 anos • 4º ano',
        escola: 'ETEC Albert Einstein',
        turno: 'Manhã',
        horario: '07:00 - 12:00',
        tipoSanguineo: 'O+',
        alergias: 'Nenhuma',
        status: 'Ativo',
      );

      final reconstruido = Filho.fromMap(filho.id!, filho.toMap());

      expect(reconstruido.id, filho.id);
      expect(reconstruido.nome, filho.nome);
      expect(reconstruido.idadeEAno, filho.idadeEAno);
      expect(reconstruido.escola, filho.escola);
      expect(reconstruido.turno, filho.turno);
      expect(reconstruido.horario, filho.horario);
      expect(reconstruido.tipoSanguineo, filho.tipoSanguineo);
      expect(reconstruido.alergias, filho.alergias);
      expect(reconstruido.status, filho.status);
    });

    test('toMap não inclui o id (o id vive fora do documento, como doc id do Firestore)', () {
      const filho = Filho(id: 'abc123', nome: 'Maria', idadeEAno: '12 anos', escola: 'X', turno: 'Tarde', horario: '13:00-18:00');

      expect(filho.toMap().containsKey('id'), isFalse);
    });

    test('fromMap usa "Ativo" como status padrão quando ausente', () {
      final filho = Filho.fromMap('id1', {'nome': 'Pedro'});

      expect(filho.status, 'Ativo');
      expect(filho.tipoSanguineo, '');
    });
  });
}
