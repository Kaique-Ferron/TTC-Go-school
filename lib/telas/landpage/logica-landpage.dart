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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(height: 20),
          const Text(
            'A segurança do seu filho\nna palma da sua mão',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50), height: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'Acompanhe o trajeto de ida e volta da escola em tempo real e tenha paz de espírito todos os dias.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF666666), height: 1.4),
          ),
          const SizedBox(height: 24),
          
          // Botão que dispara a troca para a ListView de motoristas
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: const Color(0xFF2C3E50),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: aoClicarEncontrar, 
            child: const Text('Encontrar uma Van', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 32),
          
          // O seu Mapa Fake Local
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFFFFF7D6),
                  image: const DecorationImage(
                    image: AssetImage('lib/widgets/imagens/fake-map.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: const Row(
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
          const SizedBox(height: 40),
        ],
      ),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: motoristas.length,
            itemBuilder: (context, index) {
              final mot = motoristas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFE8EEFC),
                      child: Icon(Icons.person, size: 40, color: const Color(0xFF1D58E2).withOpacity(0.5)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mot['nome'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text('${mot['corridas']} corridas concluídas', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled, size: 14, color: Color(0xFFFFC107)),
                              const SizedBox(width: 4),
                              Text('${mot['tempo']} de aplicativo', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.badge, size: 14, color: Color(0xFF1D58E2)),
                              const SizedBox(width: 4),
                              Text('CRM / Registro: ${mot['crm']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D58E2))),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}