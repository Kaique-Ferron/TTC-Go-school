import 'package:flutter/material.dart';

class ImageShowcase extends StatelessWidget {
  const ImageShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          right: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://img.freepik.com/free-vector/halftone-dots-background_1048-11231.jpg'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
          ),
        ),
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFE8EEFC),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop'), 
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}