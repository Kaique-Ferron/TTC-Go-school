import 'package:flutter/material.dart';
import '../theme/cores.dart';

class SecaoCardWrapper extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? acaoHeader;
  final Widget child;
  final IconData? icone;
  final Color? corIcone;

  const SecaoCardWrapper({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acaoHeader,
    required this.child,
    this.icone,
    this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icone != null) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (corIcone ?? Colors.grey).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icone, size: 16, color: corIcone ?? Colors.grey),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppCores.textoPrincipal(context),
                        ),
                      ),
                    ],
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo!,
                      style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                    ),
                  ],
                ],
              ),
              if (acaoHeader != null) acaoHeader!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}