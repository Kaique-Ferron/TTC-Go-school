import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tag de segurança
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, color: Color(0xFF1D58E2), size: 16),
              SizedBox(width: 6),
              Text(
                'Motoristas 100% Verificados',
                style: TextStyle(color: Color(0xFF1D58E2), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Título principal (Dor do cliente resolvida)
        const Text(
          'A segurança do seu filho\nna palma da sua mão',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C3E50), // Azul bem escuro
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        
        // Subtítulo explicativo
        const Text(
          'Acompanhe o trajeto de ida e volta da escola em tempo real e tenha paz de espírito todos os dias.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        
        // Botão de Ação com a cor da Van (Amarelo Escolar)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107), // Amarelo escolar
            foregroundColor: const Color(0xFF2C3E50), // Letra escura para contraste
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Encontrar uma Van',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}