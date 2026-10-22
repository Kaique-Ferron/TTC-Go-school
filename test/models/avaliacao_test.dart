import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/avaliacao_model.dart';

void main() {
  group('Avaliacao', () {
    test('toMap grava os campos certos (criadoEm fica a cargo do servidor)', () {
      final avaliacao = Avaliacao(
        responsavelUid: 'resp123',
        responsavelNome: 'Carlos',
        nota: 5,
        comentario: 'Motorista excelente!',
        criadoEm: DateTime(2026, 1, 1),
      );

      final mapa = avaliacao.toMap();

      expect(mapa['responsavelUid'], 'resp123');
      expect(mapa['responsavelNome'], 'Carlos');
      expect(mapa['nota'], 5);
      expect(mapa['comentario'], 'Motorista excelente!');
      // criadoEm vira um FieldValue sentinel (serverTimestamp), não uma
      // data comum — o Firestore de verdade resolve isso no servidor.
      expect(mapa['criadoEm'], isA<FieldValue>());
    });

    test('fromMap reconstrói a partir de um Timestamp real do Firestore', () {
      final data = DateTime(2026, 3, 15, 10, 30);
      final mapa = {
        'responsavelUid': 'resp456',
        'responsavelNome': 'Beatriz',
        'nota': 4,
        'comentario': 'Muito bom, só atrasou um pouco.',
        'criadoEm': Timestamp.fromDate(data),
      };

      final avaliacao = Avaliacao.fromMap(mapa);

      expect(avaliacao.responsavelUid, 'resp456');
      expect(avaliacao.responsavelNome, 'Beatriz');
      expect(avaliacao.nota, 4);
      expect(avaliacao.comentario, 'Muito bom, só atrasou um pouco.');
      expect(avaliacao.criadoEm, data);
    });

    test('fromMap preenche com valores padrão quando faltam campos', () {
      final avaliacao = Avaliacao.fromMap({});

      expect(avaliacao.responsavelUid, '');
      expect(avaliacao.responsavelNome, '');
      expect(avaliacao.nota, 0);
      expect(avaliacao.comentario, '');
    });

    test('nota aceita tanto int quanto num (Firestore às vezes devolve double)', () {
      final avaliacao = Avaliacao.fromMap({'nota': 3.0});
      expect(avaliacao.nota, 3);
      expect(avaliacao.nota, isA<int>());
    });
  });
}
