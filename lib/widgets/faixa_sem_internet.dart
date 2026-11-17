import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conectividade_provider.dart';

class FaixaSemInternet extends StatelessWidget {
  final Widget child;

  const FaixaSemInternet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConectividadeProvider>().online;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: online
              ? const SizedBox(width: double.infinity, height: 0)
              : Material(
                  color: const Color(0xFFB3261E),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Sem conexão com a internet — alguns dados podem estar desatualizados.',
                              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
