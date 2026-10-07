import 'package:flutter/material.dart';
import '../models/motorista_model.dart';
import '../theme/cores.dart';

/// Modal exibido ao Responsável quando ele toca num motorista na aba
/// Serviços — mostra foto de perfil, valor da mensalidade e quantas
/// crianças o motorista já leva por período (manhã/tarde).
class ModalDetalhesMotorista extends StatelessWidget {
  final Motorista motorista;

  const ModalDetalhesMotorista({super.key, required this.motorista});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalhes do Motorista',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Foto de perfil + nome + veículo
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFE8EEFC),
                  backgroundImage: motorista.fotoPerfil.isNotEmpty ? NetworkImage(motorista.fotoPerfil) : null,
                  child: motorista.fotoPerfil.isEmpty
                      ? const Icon(Icons.person, size: 36, color: AppCores.azulPrincipal)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(motorista.nome, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${motorista.veiculo} • ${motorista.placa}', style: TextStyle(color: Colors.grey[600], fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Valor da mensalidade — destaque principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppCores.verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppCores.verde.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.payments_outlined, color: AppCores.verde, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mensalidade', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          'R\$ ${motorista.valorMensalidade.toStringAsFixed(2).replaceAll('.', ',')} / mês',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppCores.verde),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Capacidade por período
            Row(
              children: [
                Expanded(
                  child: _blocoPeriodo(
                    icone: Icons.wb_sunny_outlined,
                    cor: AppCores.ambar,
                    titulo: 'Manhã',
                    quantidade: motorista.criancasManha,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _blocoPeriodo(
                    icone: Icons.nightlight_outlined,
                    cor: AppCores.roxo,
                    titulo: 'Tarde',
                    quantidade: motorista.criancasTarde,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _linhaInfo(Icons.badge_outlined, 'Registro: ${motorista.crm}'),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppCores.azulPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contratação em breve!')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Contratar motorista', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blocoPeriodo({required IconData icone, required Color cor, required String titulo, required int quantidade}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 15, color: cor),
              const SizedBox(width: 6),
              Text(titulo, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$quantidade criança${quantidade == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _linhaInfo(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(texto, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
}
