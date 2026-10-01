import 'package:flutter/material.dart';

class CardEstatistica extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String valor;
  final String rotulo;

  const CardEstatistica({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.valor,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      padding: const EdgeInsets.all(16),
=======
      padding: const EdgeInsets.all(12),
>>>>>>> master
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
<<<<<<< HEAD
=======
        mainAxisSize: MainAxisSize.min,
>>>>>>> master
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
<<<<<<< HEAD
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
=======
              Expanded(
                child: Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
>>>>>>> master
                ),
              ),
            ],
          ),
<<<<<<< HEAD
          const SizedBox(height: 8),
          Text(
            rotulo,
=======
          const SizedBox(height: 6),
          Text(
            rotulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
>>>>>>> master
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}