import 'package:flutter/material.dart';
import '../theme/cores.dart';

class ModalInfoFilho extends StatelessWidget {
  final String nome;
  final String idadeEAno;
  final String escola;
  final String periodo;
  final String tipoSanguineo;
  final String alergias;
  final String status;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const ModalInfoFilho({
    super.key,
    required this.nome,
    required this.idadeEAno,
    required this.escola,
    required this.periodo,
    required this.tipoSanguineo,
    required this.alergias,
    this.status = 'Ativo',
    required this.onEditar,
    required this.onExcluir,
  });

  static const Color azulPrincipal = Color(0xFF1D58E2);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppCores.superficie(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topo do Modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informações Complementares',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Header do Filho (Foto, Nome, Badge, Idade)
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F0FE),
                  child: Icon(Icons.person, size: 36, color: azulPrincipal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            nome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(color: azulPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(idadeEAno, style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cards de Dados (Grid 2x2)
            Row(
              children: [
                Expanded(child: _buildBlocoInfo(context, 'ESCOLA', escola)),
                const SizedBox(width: 12),
                Expanded(child: _buildBlocoInfo(context, 'PERÍODO', periodo)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildBlocoInfo(context, 'TIPO SANGUÍNEO', tipoSanguineo)),
                const SizedBox(width: 12),
                Expanded(child: _buildBlocoInfo(context, 'ALERGIAS', alergias)),
              ],
            ),
            const SizedBox(height: 24),

            // Botões de Ação Grandes (Excluir e Editar)
            Row(
              children: [
                // Botão Excluir
                Expanded(
                  child: InkWell(
                    onTap: onExcluir,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade400, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                        color: AppCores.superficie(context),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, size: 40, color: Colors.red.shade400),
                          const SizedBox(height: 4),
                          Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botão Editar
                Expanded(
                  child: InkWell(
                    onTap: onEditar,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: azulPrincipal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 40, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'Editar',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocoInfo(BuildContext context, String rotulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.fundo(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppCores.textoPrincipal(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}