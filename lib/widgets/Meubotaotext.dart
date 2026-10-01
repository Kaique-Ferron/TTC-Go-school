import 'package:flutter/material.dart';

Widget meuBotaoTexto(
  String texto,
  VoidCallback funcao,
) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: funcao,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}