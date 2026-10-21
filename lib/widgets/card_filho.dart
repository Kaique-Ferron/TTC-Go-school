import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardFilho extends StatelessWidget {
  final String nome;
  final String idadeEAno;
  final String escola;
  final String turno;
  final String horario;
  final String status;
  final Color corAcento;
  final VoidCallback? onTap;

  const CardFilho({
    super.key,
    required this.nome,
    required this.idadeEAno,
    required this.escola,
    required this.turno,
    required this.horario,
    this.status = 'Ativo',
    this.corAcento = const Color(0xFF1D58E2),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Os tons mais escuros da paleta de filhos (azulEscuro/laranjaEscuro)
    // ficam quase invisíveis como ícone/texto num badge translúcido sobre
    // superfície escura — corIconeLegivel troca pela variante clara só
    // nesse caso (no tema claro devolve a cor original sem alteração).
    final corIcone = AppCores.corIconeLegivel(context, corAcento);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: corAcento.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: corAcento.withValues(alpha: 0.03),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: onTap,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: corIcone.withValues(alpha: 0.16),
            child: Icon(Icons.person, color: corIcone),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppCores.textoPrincipal(context)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: corIcone,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(idadeEAno, style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 12)),
              Text(escola, style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 12)),
            ],
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 88),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.orange),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              turno,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '($horario)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: corIcone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
