import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/municipio_ibge.dart';

// API de localidades do IBGE — gratuita, sem chave.
class IbgeService {
  IbgeService._();
  static final IbgeService instance = IbgeService._();

  static const _baseUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades/municipios';

  final Map<String, MunicipioIbge> _cachePorCodigo = {};

  Future<MunicipioIbge?> buscarMunicipio(String codigoIbge) async {
    if (codigoIbge.isEmpty) return null;

    final doCache = _cachePorCodigo[codigoIbge];
    if (doCache != null) return doCache;

    try {
      final resposta = await http.get(Uri.parse('$_baseUrl/$codigoIbge')).timeout(const Duration(seconds: 10));
      if (resposta.statusCode != 200) return null;

      final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
      final municipio = MunicipioIbge.fromMap(dados);
      _cachePorCodigo[codigoIbge] = municipio;
      return municipio;
    } catch (_) {
      return null;
    }
  }
}
