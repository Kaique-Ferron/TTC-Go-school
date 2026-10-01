import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/endereco.dart';

class ViaCepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  static Future<Endereco?> buscarCep(String cep) async {
    // Remove caracteres não numéricos
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) {
      return null;
    }

    final url = Uri.parse('$_baseUrl/$cepLimpo/json/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dados = jsonDecode(response.body);
        final endereco = Endereco.fromJson(dados);

        if (endereco.erro) {
          return null;
        }

        return endereco;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}