import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

void main() {
  late FirestoreService servico;

  setUp(() {
    servico = FirestoreService.comInstancia(FakeFirebaseFirestore());
  });

  group('conversaIdPara', () {
    test('é o mesmo id independente da ordem dos uids (determinístico)', () {
      final id1 = servico.conversaIdPara('uidA', 'uidB');
      final id2 = servico.conversaIdPara('uidB', 'uidA');

      expect(id1, id2);
    });

    test('junta os dois uids ordenados alfabeticamente com "_"', () {
      final id = servico.conversaIdPara('zebra', 'abacate');
      expect(id, 'abacate_zebra');
    });
  });

  group('chamadaIdPara', () {
    test('monta o id como yyyy-MM-dd_periodo', () {
      final id = servico.chamadaIdPara(DateTime(2026, 3, 5), 'Manhã');
      expect(id, '2026-03-05_Manhã');
    });

    test('preenche mês e dia com zero à esquerda quando necessário', () {
      final id = servico.chamadaIdPara(DateTime(2026, 1, 9), 'Tarde');
      expect(id, '2026-01-09_Tarde');
    });

    test('a mesma data/período sempre gera o mesmo id (idempotente)', () {
      final id1 = servico.chamadaIdPara(DateTime(2026, 7, 20, 8, 30), 'Manhã');
      final id2 = servico.chamadaIdPara(DateTime(2026, 7, 20, 23, 59), 'Manhã');

      // Mesma data (só a hora muda) — tem que dar o mesmo id, senão a
      // chamada duplicaria em vez de atualizar.
      expect(id1, id2);
    });
  });
}
