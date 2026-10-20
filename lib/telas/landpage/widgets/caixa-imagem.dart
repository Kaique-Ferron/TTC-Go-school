import 'package:flutter/material.dart';

class ImageShowcase extends StatelessWidget {
  const ImageShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Fundo amarelo claro decorativo
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 40, right: 10, left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFFFFF7D6), // Amarelo bem clarinho e amigável
          ),
        ),
        
        // A sua imagem da Van!
        Positioned(
          bottom: 0,
          child: Image.network(
            './lib/widgets/imagens/fake-map.jpg',
            height: 200,
            fit: BoxFit.contain,
 
          ),
        ),
        
        // Badge flutuante de "Tempo Real"
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFFFF5722), size: 16),
                SizedBox(width: 4),
                Text(
                  'GPS Ativo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}