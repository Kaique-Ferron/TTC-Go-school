import 'package:flutter/material.dart';

Widget CampoTexto({
  required TextEditingController controlador,
  required String rotulo,
  required IconData icone,
  bool ocultar = false,
  TextInputType tipoTeclado = TextInputType.text,
  String? Function(String?)? validador,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controlador,
      obscureText: ocultar,
      keyboardType: tipoTeclado,
      validator: validador,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone),
        border: const OutlineInputBorder(),
      ),
    ),
  );
}