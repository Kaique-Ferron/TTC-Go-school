import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/foto_perfil_provider.dart';

void main() {
  group('fotoPerfilProvider', () {
    test('retorna null quando o valor é null', () {
      expect(fotoPerfilProvider(null), isNull);
    });

    test('retorna null quando o valor é vazio', () {
      expect(fotoPerfilProvider(''), isNull);
    });

    test('retorna NetworkImage pra uma URL http/https comum', () {
      final provider = fotoPerfilProvider('https://exemplo.com/foto.jpg');
      expect(provider, isA<NetworkImage>());
      expect((provider as NetworkImage).url, 'https://exemplo.com/foto.jpg');
    });

    test('retorna MemoryImage pra uma imagem base64 embutida (sem Firebase Storage)', () {
      final bytes = utf8.encode('fake-image-bytes');
      final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final provider = fotoPerfilProvider(dataUri);

      expect(provider, isA<MemoryImage>());
      expect((provider as MemoryImage).bytes, bytes);
    });

    test('retorna null (sem crashar) se o base64 estiver corrompido', () {
      final provider = fotoPerfilProvider('data:image/jpeg;base64,***não é base64***');
      expect(provider, isNull);
    });
  });
}
