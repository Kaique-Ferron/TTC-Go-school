import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/indicador_senha.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('não mostra nada quando a senha está vazia', (tester) async {
    await tester.pumpWidget(wrap(const IndicadorSenha(senha: '')));

    expect(find.byType(IndicadorSenha), findsOneWidget);
    expect(find.text('Pelo menos 8 caracteres'), findsNothing);
  });

  testWidgets('mostra os requisitos assim que a senha deixa de ser vazia', (tester) async {
    await tester.pumpWidget(wrap(const IndicadorSenha(senha: 'a')));

    expect(find.text('Pelo menos 8 caracteres'), findsOneWidget);
    expect(find.text('Pelo menos 1 número'), findsOneWidget);
    expect(find.text('Pelo menos 1 caractere especial (!@#\$)'), findsOneWidget);
  });

  testWidgets('marca os requisitos atendidos com ícone de check', (tester) async {
    await tester.pumpWidget(wrap(const IndicadorSenha(senha: 'Senha123!')));

    // 8+ caracteres, tem número e tem caractere especial: os 3 requisitos atendidos.
    expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    expect(find.byIcon(Icons.cancel_outlined), findsNothing);
  });

  testWidgets('não estoura layout em telas estreitas (regressão do overflow)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 90, child: IndicadorSenha(senha: 'a')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
