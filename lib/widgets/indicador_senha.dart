import 'package:flutter/material.dart';

class IndicadorSenha extends StatelessWidget {
  final String senha;

  const IndicadorSenha({super.key, required this.senha});

  bool get temOitoCaracteres => senha.length >= 8;
  bool get temNumero => senha.contains(RegExp(r'[0-9]'));
  bool get temEspecial => senha.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get forcaSenha {
    int pontos = 0;
    if (temOitoCaracteres) pontos++;
    if (temNumero) pontos++;
    if (temEspecial) pontos++;
    return pontos;
  }

  @override
  Widget build(BuildContext context) {
    if (senha.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index < forcaSenha
                      ? (forcaSenha == 1 ? Colors.red : forcaSenha == 2 ? Colors.orange : Colors.green)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        _buildRequisito('Pelo menos 8 caracteres', temOitoCaracteres),
        _buildRequisito('Pelo menos 1 número', temNumero),
        _buildRequisito('Pelo menos 1 caractere especial (!@#\$)', temEspecial),
      ],
    );
  }

  Widget _buildRequisito(String texto, bool atendido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            atendido ? Icons.check_circle : Icons.cancel_outlined,
            size: 14,
            color: atendido ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              color: atendido ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}