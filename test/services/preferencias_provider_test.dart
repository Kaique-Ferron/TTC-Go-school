import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/preferencias_provider.dart';

void main() {
  group('PreferenciasProvider', () {
    test('começa em Automático/Média por padrão', () {
      final prefs = PreferenciasProvider();
      expect(prefs.tema, 'Automático');
      expect(prefs.tamanhoFonte, 'Média');
      expect(prefs.themeMode, ThemeMode.system);
      expect(prefs.escalaFonte, 1.0);
    });

    test('salvar() aplica o tema/fonte na hora, sem esperar o Firestore', () async {
      final prefs = PreferenciasProvider();
      // Sem usuário logado, salvar() atualiza o estado local e retorna sem
      // tentar gravar no Firestore (uid nulo) — dá pra testar isso sem
      // inicializar o Firebase.
      await prefs.salvar(tema: 'Escuro', tamanhoFonte: 'Grande');

      expect(prefs.tema, 'Escuro');
      expect(prefs.tamanhoFonte, 'Grande');
    });

    group('themeMode', () {
      test('Claro -> ThemeMode.light', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Claro', tamanhoFonte: 'Média');
        expect(prefs.themeMode, ThemeMode.light);
      });

      test('Escuro -> ThemeMode.dark', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Escuro', tamanhoFonte: 'Média');
        expect(prefs.themeMode, ThemeMode.dark);
      });

      test('Automático (ou qualquer outro valor) -> ThemeMode.system', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Automático', tamanhoFonte: 'Média');
        expect(prefs.themeMode, ThemeMode.system);
      });
    });

    group('escalaFonte', () {
      test('Pequena -> 0.9', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Claro', tamanhoFonte: 'Pequena');
        expect(prefs.escalaFonte, 0.9);
      });

      test('Média -> 1.0', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Claro', tamanhoFonte: 'Média');
        expect(prefs.escalaFonte, 1.0);
      });

      test('Grande -> 1.2', () async {
        final prefs = PreferenciasProvider();
        await prefs.salvar(tema: 'Claro', tamanhoFonte: 'Grande');
        expect(prefs.escalaFonte, 1.2);
      });
    });

    test('notifica os listeners quando salvar() é chamado', () async {
      final prefs = PreferenciasProvider();
      var notificacoes = 0;
      prefs.addListener(() => notificacoes++);

      await prefs.salvar(tema: 'Escuro', tamanhoFonte: 'Grande');

      expect(notificacoes, greaterThanOrEqualTo(1));
    });
  });
}
