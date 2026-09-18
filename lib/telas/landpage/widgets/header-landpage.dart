import 'package:flutter/material.dart';
import '../../../widgets/logo_goschool.dart';

class HeaderLandpage extends StatelessWidget {
  const HeaderLandpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 24, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2B7A), Color(0xFF1D58E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: LogoGoSchool(imageHeight: 34, fontSize: 20, corClara: true),
      ),
    );
  }
}
