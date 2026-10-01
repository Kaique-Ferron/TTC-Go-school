import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/theme/cores.dart';

void main() {
  group('AppCores.porPerfil', () {
    test('retorna azulPrincipal para Responsável', () {
      expect(AppCores.porPerfil('Responsável'), AppCores.azulPrincipal);
    });

    test('retorna laranjaMotorista para Motorista', () {
      expect(AppCores.porPerfil('Motorista'), AppCores.laranjaMotorista);
    });

    test('retorna laranjaMotorista para qualquer valor diferente de Responsável', () {
      expect(AppCores.porPerfil('qualquer coisa'), AppCores.laranjaMotorista);
    });
  });
}
