import 'package:flutter/material.dart';
import '../theme/cores.dart';

class BannerBoasVindas extends StatelessWidget {
  final bool temFilhos;
  final VoidCallback onCadastrarFilho;

  const BannerBoasVindas({
    super.key,
    required this.temFilhos,
    required this.onCadastrarFilho,
  });

  @override
  Widget build(BuildContext context) {
    if (temFilhos) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.azulPrincipal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('👏', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bem-vindo ao GoSchool! Para solicitar uma vaga é necessário cadastrar pelo menos um filho.',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              if (!isWide) const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onCadastrarFilho,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppCores.azulPrincipal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Text('Cadastrar filho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                label: const Icon(Icons.chevron_right, size: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}