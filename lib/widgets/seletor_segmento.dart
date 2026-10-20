import 'package:flutter/material.dart';
import '../theme/cores.dart';

class OpcaoSegmento<T> {
  final T valor;
  final String rotulo;
  final IconData? icone;

  const OpcaoSegmento({
    required this.valor,
    required this.rotulo,
    this.icone,
  });
}

class SeletorSegmentado<T> extends StatelessWidget {
  final List<OpcaoSegmento<T>> opcoes;
  final T valorSelecionado;
  final ValueChanged<T> onAlterado;

  const SeletorSegmentado({
    super.key,
    required this.opcoes,
    required this.valorSelecionado,
    required this.onAlterado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: opcoes.map((opcao) {
          final bool selecionado = opcao.valor == valorSelecionado;
          return Expanded(
            child: GestureDetector(
              onTap: () => onAlterado(opcao.valor),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selecionado ? AppCores.azulPrincipal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (opcao.icone != null) ...[
                      Icon(
                        opcao.icone,
                        size: 16,
                        color: selecionado ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opcao.rotulo,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                        color: selecionado ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}