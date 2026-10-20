import 'package:flutter/material.dart';
import '../theme/cores.dart';

class MotoristaModel {
  final String id;
  final String nome;
  final double avaliacao;
  final int totalAvaliacoes;
  final String veiculo;
  final List<String> escolasAtendidas;
  final int vagasDisponiveis;
  final String? fotoUrl;

  const MotoristaModel({
    required this.id,
    required this.nome,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.veiculo,
    required this.escolasAtendidas,
    required this.vagasDisponiveis,
    this.fotoUrl,
  });
}

class CardMotorista extends StatelessWidget {
  final MotoristaModel motorista;
  final bool temFilhoCadastrado;
  final VoidCallback onSolicitarVaga;

  const CardMotorista({
    super.key,
    required this.motorista,
    required this.temFilhoCadastrado,
    required this.onSolicitarVaga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: Foto, Nome, Selo Verificado, Avaliação e Veículo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppCores.azulPrincipal.withValues(alpha: 0.1),
                child: const Icon(Icons.person, size: 32, color: AppCores.azulPrincipal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            motorista.nome,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: AppCores.azulPrincipal),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${motorista.avaliacao}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${motorista.totalAvaliacoes})',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.directions_bus_outlined, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            motorista.veiculo,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'Escolas atendidas:',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),

          // Chips com as escolas atendidas
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: motorista.escolasAtendidas.map((escola) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  escola,
                  style: const TextStyle(fontSize: 10.5, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          Text(
            '${motorista.vagasDisponiveis} vagas disponíveis',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),

          // Botão Bloqueado ou Desbloqueado conforme posse de filho cadastrado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: temFilhoCadastrado ? onSolicitarVaga : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: temFilhoCadastrado ? AppCores.azulPrincipal : Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: Icon(
                temFilhoCadastrado ? Icons.send : Icons.lock_outlined,
                size: 15,
                color: temFilhoCadastrado ? Colors.white : Colors.grey.shade600,
              ),
              label: Text(
                'Solicitar vaga',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: temFilhoCadastrado ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),

          if (!temFilhoCadastrado) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Cadastre um filho para desbloquear esta função.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}