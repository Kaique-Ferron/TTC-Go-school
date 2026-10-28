import 'package:flutter/material.dart';
import '../../models/mensalidade_model.dart';
import '../../repositories/mensalidade_repository.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/cores.dart';
import '../../widgets/shell_motorista.dart';

/// Tela de Finanças do Motorista — mostra as mensalidades que caem pra ele
/// a cada mês, lidas em tempo real de usuarios/{uid}/mensalidades.
/// Enquanto não há nenhum documento lá, oferece um botão pra semear os
/// dados de exemplo (ver MensalidadeRepository + FirestoreService.semearMensalidadesMock
/// e firestore/MIGRATIONS.md para o schema).
class TelaFinancasMotorista extends StatefulWidget {
  /// Sobrescritas usadas em testes de widget (injeta um uid e um
  /// FirestoreService fake em vez dos singletons reais). Em produção ficam
  /// nulas e a tela usa AuthService/FirestoreService normalmente.
  @visibleForTesting
  final String? uidParaTeste;
  @visibleForTesting
  final FirestoreService? servicoParaTeste;

  const TelaFinancasMotorista({super.key, this.uidParaTeste, this.servicoParaTeste});

  @override
  State<TelaFinancasMotorista> createState() => _TelaFinancasMotoristaState();
}

class _TelaFinancasMotoristaState extends State<TelaFinancasMotorista> {
  bool _semeando = false;
  String _filtro = 'Todos';

  FirestoreService get _servico => widget.servicoParaTeste ?? FirestoreService.instance;

  // Criado uma única vez — se fosse recriado a cada build (ex.: ao trocar o
  // filtro Todos/Pagos/Pendentes), o StreamBuilder reinterpretaria como uma
  // troca de stream e voltaria a exibir o spinner a cada toque.
  Stream<List<Mensalidade>>? _mensalidadesStream;

  @override
  void initState() {
    super.initState();
    final uid = widget.uidParaTeste ?? AuthService.instance.uidAtual;
    if (uid != null) _mensalidadesStream = _servico.mensalidadesStream(uid);
  }

  Future<void> _semearDadosDeExemplo(String uid) async {
    setState(() => _semeando = true);
    try {
      await _servico.semearMensalidadesMock(
        uid,
        MensalidadeRepository.obterMensalidades(),
      );
    } finally {
      if (mounted) setState(() => _semeando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.uidParaTeste ?? AuthService.instance.uidAtual;

    return ShellMotorista(
      itemSelecionado: 'Finanças',
      builder: (context) => uid == null
          ? const Center(child: Text('Utilizador não autenticado.'))
          : StreamBuilder<List<Mensalidade>>(
              stream: _mensalidadesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensalidades = snapshot.data ?? [];

                if (mensalidades.isEmpty) {
                  return _buildEstadoVazio(uid);
                }

                return _buildConteudo(mensalidades);
              },
            ),
    );
  }

  Widget _buildEstadoVazio(String uid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppCores.verde.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.payments_outlined, size: 40, color: AppCores.verde),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma mensalidade registrada ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.azulPrincipal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _semeando ? null : () => _semearDadosDeExemplo(uid),
              icon: _semeando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined, color: Colors.white),
              label: const Text('Carregar dados de exemplo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo(List<Mensalidade> mensalidades) {
    final recebido = mensalidades.where((m) => m.pago).fold<double>(0, (soma, m) => soma + m.valor);
    final pendente = mensalidades.where((m) => !m.pago).fold<double>(0, (soma, m) => soma + m.valor);
    final total = recebido + pendente;
    final progresso = total == 0 ? 0.0 : recebido / total;

    final mensalidadesFiltradas = mensalidades.where((m) {
      if (_filtro == 'Pagos') return m.pago;
      if (_filtro == 'Pendentes') return !m.pago;
      return true;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 760;

        final colunaResumo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardBalanco(recebido, total, progresso),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _cardResumo('Recebido', recebido, AppCores.verde, Icons.check_circle_outline)),
                const SizedBox(width: 12),
                Expanded(child: _cardResumo('Pendente', pendente, AppCores.ambar, Icons.schedule)),
              ],
            ),
          ],
        );

        final colunaHistorico = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Histórico de pagamentos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${mensalidadesFiltradas.length}', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildChipsFiltro(),
            const SizedBox(height: 14),
            if (mensalidadesFiltradas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum pagamento neste filtro.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              )
            else
              ...mensalidadesFiltradas.map(_cardMensalidade),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Finanças', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 90, 143, 228))),
              const SizedBox(height: 4),
              Text('Mensalidades recebidas dos responsáveis este mês.', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              SizedBox(height: isWide ? 28 : 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: colunaResumo),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: colunaHistorico),
                  ],
                )
              else ...[
                colunaResumo,
                const SizedBox(height: 24),
                colunaHistorico,
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardBalanco(double recebido, double total, double progresso) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppCores.azulPrincipal, Color(0xFF3B7BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppCores.azulPrincipal.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total do mês', style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progresso * 100).toStringAsFixed(0)}% já recebido',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsFiltro() {
    return Row(
      children: [
        _chipFiltro('Todos'),
        const SizedBox(width: 8),
        _chipFiltro('Pagos'),
        const SizedBox(width: 8),
        _chipFiltro('Pendentes'),
      ],
    );
  }

  Widget _chipFiltro(String rotulo) {
    final bool ativo = _filtro == rotulo;
    return GestureDetector(
      onTap: () => setState(() => _filtro = rotulo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? AppCores.azulPrincipal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ativo ? AppCores.azulPrincipal : Colors.grey.shade300),
        ),
        child: Text(
          rotulo,
          style: TextStyle(color: ativo ? Colors.white : const Color.fromARGB(255, 254, 157, 0), fontSize: 12.5, fontWeight: FontWeight.bold),
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
                Text(m.responsavelNome, style: const TextStyle(color: const Color.fromARGB(255, 5, 14, 84),fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Filho: ${m.filhoNome}', style: TextStyle(color: const Color.fromARGB(255, 22, 1, 128), fontSize: 12), overflow: TextOverflow.ellipsis),
                Text('${m.data.day.toString().padLeft(2, '0')}/${m.data.month.toString().padLeft(2, '0')}/${m.data.year}',
                    style: TextStyle(color: const Color.fromARGB(255, 7, 1, 67), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
