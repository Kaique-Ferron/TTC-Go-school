import 'package:flutter/material.dart';

class NavChips extends StatelessWidget {
  const NavChips({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> menus = ['Início', 'Serviços', 'Galeria', 'Contato'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menus.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0; 
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                menus[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1D58E2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1D58E2),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : const Color(0xFF1D58E2),
                ),
              ),
              onSelected: (bool selected) {},
            ),
          );
        },
      ),
    );
  }
}