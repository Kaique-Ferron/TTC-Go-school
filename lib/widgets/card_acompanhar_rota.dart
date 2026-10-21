import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardAcompanharRota extends StatelessWidget {
  final String proximaParada;
  final String chegadaPrevista;
  final String tempoRestante;
  final VoidCallback? onVerDetalhes;

  const CardAcompanharRota({
    super.key,
    this.proximaParada = 'Rua das Flores, 245',
    this.chegadaPrevista = '08:15',
    this.tempoRestante = 'Faltam 12 min',
    this.onVerDetalhes,
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
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: Colors.blue.shade800, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Acompanhar rota',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onVerDetalhes,
                child: Row(
                  children: const [
                    Text('Ver detalhes', style: TextStyle(fontSize: 12, color: AppCores.laranjaMotorista, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 16, color: AppCores.laranjaMotorista),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Área da Prévia do Mapa com Pins e Ícone da Van
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://tile.openstreetmap.org/15/9326/19225.png'), // Imagem de mapa estático
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Stack(
              children: [
                // Badge Próxima Parada
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Próxima parada', style: TextStyle(color: Colors.white70, fontSize: 9)),
                            Text(proximaParada, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Card de Chegada Prevista
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppCores.azulPrincipal),
                            const SizedBox(width: 4),
                            Text('Chegada prevista $chegadaPrevista', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, size: 12, color: AppCores.azulPrincipal),
                            const SizedBox(width: 4),
                            Text(tempoRestante, style: const TextStyle(fontSize: 10, color: AppCores.azulPrincipal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Ícone da Van no Centro do Rota
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppCores.azulPrincipal, shape: BoxShape.circle),
                    child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Linha do tempo simples de progresso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEtapaLinha('Embarque', '07:40', Icons.directions_bus, AppCores.laranjaMotorista),
              _buildDivisorLinha(true),
              _buildEtapaLinha('A caminho', '08:00', Icons.directions_bus, AppCores.azulPrincipal),
              _buildDivisorLinha(false),
              _buildEtapaLinha('Escola', '08:15', Icons.home_work, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEtapaLinha(String rotulo, String hora, IconData icone, Color cor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: cor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icone, size: 14, color: cor),
        ),
        const SizedBox(height: 4),
        Text(rotulo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(hora, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDivisorLinha(bool ativo) {
    return Expanded(
      child: Container(
        height: 2,
        color: ativo ? AppCores.azulPrincipal : Colors.grey.shade300,
      ),
    );
  }
}