import 'package:flutter/material.dart';
import '../theme/cores.dart';

class SeletorTurno extends StatelessWidget {
  final String turnoSelecionado;
  final ValueChanged<String> onTurnoSelecionado;

  const SeletorTurno({
    super.key,
    required this.turnoSelecionado,
    required this.onTurnoSelecionado,
  });

  static const List<String> turnos = ['Manhã', 'Tarde', 'Integral'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turno da Escola',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: turnos.map((turno) {
            final bool selecionado = turnoSelecionado == turno;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => onTurnoSelecionado(turno),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selecionado ? AppCores.azulPrincipal : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selecionado ? AppCores.azulPrincipal : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        turno,
                        style: TextStyle(
                          color: selecionado ? Colors.white : Colors.black87,
                          fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}