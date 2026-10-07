import 'package:flutter/material.dart';
import '../../models/mensalidade_model.dart';
import '../../repositories/mensalidade_repository.dart';
import '../../theme/cores.dart';

/// Tela de Finanças do Motorista — mostra as mensalidades que caem pra ele
/// a cada mês. Dados mockados por enquanto (ver MensalidadeRepository);
/// trocar pela consulta real ao Firestore é só mudar a fonte de dados aqui.
class TelaFinancasMotorista extends StatelessWidget {
  const TelaFinancasMotorista({super.key});

  @override
  Widget build(BuildContext context) {
    final mensalidades = MensalidadeRepository.obterMensalidades();
    final recebido = mensalidades.where((m) => m.pago).fold<double>(0, (soma, m) => soma + m.valor);
    final pendente = mensalidades.where((m) => !m.pago).fold<double>(0, (soma, m) => soma + m.valor);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Finanças'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mensalidades recebidas dos responsáveis este mês.', style: TextStyle(color: Colors.grey[600], fontSize: 13.5)),
            const SizedBox(height: 20),

            // Resumo: recebido x pendente
            Row(
              children: [
                Expanded(child: _cardResumo('Recebido', recebido, AppCores.verde, Icons.check_circle_outline)),
                const SizedBox(width: 12),
                Expanded(child: _cardResumo('Pendente', pendente, AppCores.ambar, Icons.schedule)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Histórico de pagamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...mensalidades.map(_cardMensalidade),
          ],
        ),
      ),
    );
  }

  Widget _cardResumo(String titulo, double valor, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icone, size: 18, color: cor),
          ),
          const SizedBox(height: 10),
          Text(titulo, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: cor),
          ),
        ],
      ),
    );
  }

  Widget _cardMensalidade(Mensalidade m) {
    final cor = m.pago ? AppCores.verde : AppCores.ambar;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8EEFC),
            child: const Icon(Icons.person, color: AppCores.azulPrincipal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.responsavelNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Filho: ${m.filhoNome}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text('${m.data.day.toString().padLeft(2, '0')}/${m.data.month.toString().padLeft(2, '0')}/${m.data.year}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${m.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                child: Text(m.status, style: TextStyle(color: cor, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
