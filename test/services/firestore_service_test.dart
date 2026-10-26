import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/usuario.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreService servico;

  setUp(() {
    db = FakeFirebaseFirestore();
    servico = FirestoreService.comInstancia(db);
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

  group('perfil público do motorista (motoristas_publico)', () {
    const motorista = Usuario(
      nome: 'Carlos Henrique',
      email: 'carlos@teste.com',
      telefone: '11999999999',
      cpf: '12345678900',
      perfil: 'Motorista',
      cnh: 'ABC123',
      licenca: 'ABC123',
      placa: 'XYZ-1234',
      veiculo: 'Van Sprinter',
    );

    test('salvarUsuario espelha os campos públicos, sem o cpf/cnh', () async {
      await servico.salvarUsuario('motorista1', motorista);

      final publico = await db.collection('motoristas_publico').doc('motorista1').get();
      final dados = publico.data()!;

      expect(dados['nome'], 'Carlos Henrique');
      expect(dados['veiculo'], 'Van Sprinter');
      expect(dados['placa'], 'XYZ-1234');
      expect(dados['licenca'], 'ABC123');
      expect(dados.containsKey('cpf'), isFalse);
      expect(dados.containsKey('cnh'), isFalse);
      expect(dados.containsKey('endereco'), isFalse);
    });

    test('salvarUsuario NÃO cria perfil público para Responsável', () async {
      const responsavel = Usuario(
        nome: 'Ana',
        email: 'ana@teste.com',
        telefone: '11988888888',
        cpf: '00000000000',
        perfil: 'Responsável',
      );

      await servico.salvarUsuario('responsavel1', responsavel);

      final publico = await db.collection('motoristas_publico').doc('responsavel1').get();
      expect(publico.exists, isFalse);
    });

    test('atualizarUsuario mantém o perfil público em sincronia (ex.: troca de foto)', () async {
      await servico.salvarUsuario('motorista2', motorista);

      await servico.atualizarUsuario('motorista2', {
        'fotoPerfil': 'data:image/jpeg;base64,abc123',
      });

      final publico = await db.collection('motoristas_publico').doc('motorista2').get();
      expect(publico.data()!['fotoPerfil'], 'data:image/jpeg;base64,abc123');
      // O update parcial não tocou no resto — continua espelhado certo.
      expect(publico.data()!['nome'], 'Carlos Henrique');
    });

    test('motoristasStream só devolve o que está no perfil público', () async {
      await servico.salvarUsuario('motorista3', motorista);

      final lista = await servico.motoristasStream().first;

      expect(lista, hasLength(1));
      expect(lista.first.nome, 'Carlos Henrique');
      expect(lista.first.placa, 'XYZ-1234');
    });
  });

  group('notificação de mensagem nova (push)', () {
    test('enviarMensagem atualiza a conversa mesmo sem ninguém inscrito pra push (não trava)', () async {
      final conversaId = await servico.obterOuCriarConversa(
        meuUid: 'responsavel1',
        meuNome: 'Ana',
        outroUid: 'motorista1',
        outroNome: 'Carlos',
      );

      await servico.enviarMensagem(conversaId: conversaId, remetenteUid: 'responsavel1', texto: 'Oi!');

      final conversa = await db.collection('conversas').doc(conversaId).get();
      expect(conversa.data()!['ultimaMensagem'], 'Oi!');
    });

    test('enviarMensagem não falha quando o destinatário tem um id de push salvo', () async {
      final conversaId = await servico.obterOuCriarConversa(
        meuUid: 'responsavel1',
        meuNome: 'Ana',
        outroUid: 'motorista1',
        outroNome: 'Carlos',
      );
      await db.collection('conversas').doc(conversaId).set({
        'participantesPushIds': {'motorista1': 'subscription-fake-123'},
      }, SetOptions(merge: true));

      await servico.enviarMensagem(conversaId: conversaId, remetenteUid: 'responsavel1', texto: 'Oi de novo!');

      final conversa = await db.collection('conversas').doc(conversaId).get();
      expect(conversa.data()!['ultimaMensagem'], 'Oi de novo!');
    });
  });

  group('paradasRotaStream (Minhas Rotas do Motorista)', () {
    Future<void> criarContratacao(
      String responsavelUid, {
      required String motoristaUid,
      required String periodo,
      required List<String> filhosNomes,
      double? lat,
      double? lng,
    }) {
      return db
          .collection('usuarios')
          .doc(responsavelUid)
          .collection('contratacoes')
          .add({
            'motoristaUid': motoristaUid,
            'responsavelNome': 'Resp $responsavelUid',
            'responsavelLat': lat,
            'responsavelLng': lng,
            'responsavelEndereco': 'Rua $responsavelUid',
            'filhosNomes': filhosNomes,
            'periodo': periodo,
            'status': 'Ativo',
          });
    }

    test('agrupa filhos do mesmo responsável/período numa única parada', () async {
      await criarContratacao('resp1', motoristaUid: 'motorista1', periodo: 'Manhã', filhosNomes: ['Ana'], lat: -23.5, lng: -46.6);
      await criarContratacao('resp2', motoristaUid: 'motorista1', periodo: 'Manhã', filhosNomes: ['Bia'], lat: -23.6, lng: -46.7);
      // De outro motorista — não deve aparecer na rota do motorista1.
      await criarContratacao('resp3', motoristaUid: 'motorista2', periodo: 'Manhã', filhosNomes: ['Caio']);

      final paradas = await FirestoreService.comInstancia(db).paradasRotaStream('motorista1').first;

      expect(paradas, hasLength(2));
      expect(paradas.every((p) => p.temLocalizacao), isTrue);
    });

    test('contratação sem status Ativo não vira parada', () async {
      final ref = await db
          .collection('usuarios')
          .doc('resp1')
          .collection('contratacoes')
          .add({
            'motoristaUid': 'motorista1',
            'responsavelNome': 'Resp',
            'filhosNomes': ['Ana'],
            'periodo': 'Manhã',
            'status': 'Cancelado',
          });
      await ref.get(); // só garante que o doc existe antes de ler o stream

      final paradas = await FirestoreService.comInstancia(db).paradasRotaStream('motorista1').first;

      expect(paradas, isEmpty);
    });

    test('parada sem lat/lng marca temLocalizacao como falso', () async {
      await criarContratacao('resp1', motoristaUid: 'motorista1', periodo: 'Tarde', filhosNomes: ['Ana']);

      final paradas = await FirestoreService.comInstancia(db).paradasRotaStream('motorista1').first;

      expect(paradas.single.temLocalizacao, isFalse);
    });
  });
}
