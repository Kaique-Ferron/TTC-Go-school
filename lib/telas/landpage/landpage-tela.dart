import 'package:flutter/material.dart';
import 'package:flutter_application_1/telas/landpage/widgets/footer_icons.dart';
import 'package:flutter_application_1/telas/landpage/widgets/hero_section.dart';
import 'package:flutter_application_1/telas/landpage/widgets/image_showcase.dart';
import 'package:flutter_application_1/telas/landpage/widgets/nav_chips.dart';

import '../../widgets/logo_goschool.dart'; 

import 'widgets/nav_chips.dart';
import 'widgets/hero_section.dart';
import 'widgets/image_showcase.dart';
import 'widgets/footer_icons.dart';

class LandpageTela extends StatelessWidget {
  const LandpageTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        // 1. Centraliza tudo na tela (útil para Web/Desktop)
        child: Center(
          // 2. Trava a largura máxima no tamanho de um celular (ex: 450px)
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ad',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF888888)),
                        ),
                        const LogoGoSchool(fontSize: 22.0),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF888888)),
                          onPressed: () {
                            print('Fechar Landing Page');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // NAV CHIPS
                    const NavChips(),
                    const SizedBox(height: 40),

                    // HERO SECTION
                    const HeroSection(),
                    const SizedBox(height: 40),

                    // IMAGEM
                    const ImageShowcase(),
                    const SizedBox(height: 32),

                    // ÍCONES
                    const FooterIcons(),
                    const SizedBox(height: 24),

                    // TEXTO FINAL
                    const Text(
                      'CONHEÇA NOSSAS ROTAS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}