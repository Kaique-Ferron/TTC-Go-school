import 'package:flutter/material.dart';

// ============================================================================
// CONTEÚDO DA ABA 0: INÍCIO (Com o botão que muda o front inteiro)
// ============================================================================
class AbaInicio extends StatelessWidget {
  final VoidCallback aoClicarEncontrar;

  const AbaInicio({super.key, required this.aoClicarEncontrar});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFE8EEFC), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF1D58E2), size: 16),
                SizedBox(width: 6),
                Text('Motoristas 100% Verificados', style: TextStyle(color: Color(0xFF1D58E2), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'A segurança do seu filho\nna palma da sua mão',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.25),
          ),
          const SizedBox(height: 14),
          const Text(
            'Acompanhe o trajeto de ida e volta da escola em tempo real e tenha paz de espírito todos os dias.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 26),

          // Botão que dispara a troca para a ListView de motoristas
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: aoClicarEncontrar,
            icon: const Icon(Icons.directions_bus_rounded, size: 20),
            label: const Text('Encontrar uma Van', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 32),

          // Cartão com o mapa ilustrativo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFFFFF7D6),
                  image: const DecorationImage(
                    image: AssetImage('lib/widgets/imagens/fake-map.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFFF5722), size: 16),
                      SizedBox(width: 4),
                      Text('GPS Ativo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Mini estatísticas de confiança
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildEstatistica('50+', 'Motoristas\nverificados')),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(child: _buildEstatistica('500+', 'Famílias\natendidas')),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(child: _buildEstatistica('4.9 ★', 'Avaliação\nmédia')),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEstatistica(String numero, String rotulo) {
    return Column(
      children: [
        Text(numero, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1D58E2))),
        const SizedBox(height: 4),
        Text(
          rotulo,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: Colors.grey[600], height: 1.3),
        ),
      ],
    );
  }
}

// ============================================================================
// CONTEÚDO DA ABA 1: SERVIÇOS (ListView Completa dos Motoristas)
// ============================================================================
class AbaMotoristas extends StatelessWidget {
  const AbaMotoristas({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> motoristas = [
      {'nome': 'Carlos Silva', 'corridas': '1.240', 'tempo': '3 anos', 'crm': '48392-SP'},
      {'nome': 'Mariana Souza', 'corridas': '811', 'tempo': '1 ano', 'crm': '19455-SP'},
      {'nome': 'Roberto Alves', 'corridas': '3.450', 'tempo': '2.5 anos', 'crm': '98561-SP'},
      {'nome': 'Leticia Lopes', 'corridas': '1.234', 'tempo': '12 anos', 'crm': '95321-SP'},
      {'nome': 'Felipe Alcantra', 'corridas': '2.240', 'tempo': '1 anos', 'crm': '95421-SP'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motoristas Disponíveis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text('Todos verificados e avaliados pela comunidade.', style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
          const SizedBox(height: 18),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: motoristas.length,
            itemBuilder: (context, index) {
              final mot = motoristas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE8EEFC),
                      child: const Icon(Icons.person, size: 30, color: Color(0xFF1D58E2)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mot['nome'], style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _buildDetalhe(Icons.check_circle, Colors.green, '${mot['corridas']} corridas'),
                              _buildDetalhe(Icons.access_time_filled, const Color(0xFFFFC107), mot['tempo']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildDetalhe(Icons.badge, const Color(0xFF1D58E2), 'Registro ${mot['crm']}', destaque: true),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetalhe(IconData icone, Color cor, String texto, {bool destaque = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: cor),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11.5,
            color: destaque ? cor : Colors.grey[600],
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
