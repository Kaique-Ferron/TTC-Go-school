import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/header-landpage.dart';
import 'logica-landpage.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../widgets/nav_inferior_responsavel.dart';

class LandpageTela extends StatefulWidget {
  const LandpageTela({super.key});

  @override
  State<LandpageTela> createState() => _LandpageTelaState();
}

class _LandpageTelaState extends State<LandpageTela> {
  int _abaSelecionada = 0;
  final List<String> _menus = ['Início', 'Serviços'];

  static const Color azulPrincipal = Color(0xFF1D58E2);

  // Ao clicar em "Encontrar uma Van": se o responsável ainda não cadastrou
  // nenhum filho, manda ele cadastrar primeiro em vez de mostrar a lista
  // de motoristas (não faz sentido contratar transporte sem um filho).
  Future<void> _aoClicarEncontrarVan() async {
    final uid = context.read<SessaoProvider>().uid;
    if (uid == null) {
      setState(() => _abaSelecionada = 1);
      return;
    }

    final filhos = await FirestoreService.instance.filhosStream(uid).first;
    if (!mounted) return;

    if (filhos.isEmpty) {
      Navigator.pushNamed(context, '/meus-filhos');
    } else {
      setState(() => _abaSelecionada = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Início'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              const HeaderLandpage(),
              const SizedBox(height: 20),

              // Seletor de abas em formato pill, centralizado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_menus.length, (index) {
                      final bool isSelected = _abaSelecionada == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _abaSelecionada = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? azulPrincipal : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _menus[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
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
          aoClicarEncontrar: _aoClicarEncontrarVan,
        );
      case 1:
      default:
        return const AbaMotoristas(key: ValueKey(1));
    }
  }
}
