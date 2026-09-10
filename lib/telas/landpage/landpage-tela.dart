import 'package:flutter/material.dart';
import 'widgets/header-landpage.dart';
import 'logica-landpage.dart';

class LandpageTela extends StatefulWidget {
  const LandpageTela({super.key});

  @override
  State<LandpageTela> createState() => _LandpageTelaState();
}

class _LandpageTelaState extends State<LandpageTela> {
  int _abaSelecionada = 0;
  final List<String> _menus = ['Início', 'Serviços', 'Galeria', 'Contato'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              const HeaderLandpage(),
              const SizedBox(height: 20),

              // Menu superior de navegação
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _abaSelecionada == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(
                          _menus[index],
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
                        onSelected: (bool selected) {
                          setState(() {
                            _abaSelecionada = index;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Corpo dinâmico alterado pelo clique do botão ou menu
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _construirConteudoDaAba(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirConteudoDaAba() {
    switch (_abaSelecionada) {
      case 0:
        return AbaInicio(
          key: const ValueKey(0),
          aoClicarEncontrar: () {
            setState(() {
              _abaSelecionada = 1; // Muda instantaneamente o front para a ListView de motoristas
            });
          },
        );
      case 1:
        return const AbaMotoristas(key: ValueKey(1));
      default:
        return Center(
          key: ValueKey(_abaSelecionada),
          child: const Text('Conteúdo em construção...', style: TextStyle(color: Colors.grey)),
        );
    }
  }
}