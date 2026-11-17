import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feriado.dart';

// API de feriados nacionais (BrasilAPI) — gratuita, sem chave.
class FeriadosService {
  FeriadosService._();
  static final FeriadosService instance = FeriadosService._();

  static const _baseUrl = 'https://brasilapi.com.br/api/feriados/v1';

  final Map<int, List<Feriado>> _cachePorAno = {};

  Future<List<Feriado>> buscarFeriados(int ano) async {
    final doCache = _cachePorAno[ano];
    if (doCache != null) return doCache;

    try {
      final resposta = await http.get(Uri.parse('$_baseUrl/$ano')).timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) return [];

      final lista = jsonDecode(resposta.body) as List;
      final feriados = lista.map((item) => Feriado.fromMap(item as Map<String, dynamic>)).toList();
      _cachePorAno[ano] = feriados;
      return feriados;
    } catch (_) {
      return [];
    }
  }

  Future<Feriado?> feriadoDeHoje() async {
    final feriados = await buscarFeriados(DateTime.now().year);
    for (final feriado in feriados) {
      if (feriado.ehHoje) return feriado;
    }
    return null;
  }
}
