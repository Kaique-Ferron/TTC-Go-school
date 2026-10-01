import 'package:flutter/material.dart';

class FooterIcons extends StatelessWidget {
  const FooterIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.language,
      Icons.phone_outlined,
      Icons.email_outlined,
      Icons.share_outlined,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons.map((icon) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF333333)),
            onPressed: () {},
          ),
        );
      }).toList(),
    );
  }
}