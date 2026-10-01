import 'package:flutter/material.dart';

class SecaoCardWrapper extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? acaoHeader;
  final Widget child;
<<<<<<< HEAD
=======
  final IconData? icone;
  final Color? corIcone;
>>>>>>> master

  const SecaoCardWrapper({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acaoHeader,
    required this.child,
<<<<<<< HEAD
=======
    this.icone,
    this.corIcone,
>>>>>>> master
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
<<<<<<< HEAD
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
=======
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
>>>>>>> master
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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