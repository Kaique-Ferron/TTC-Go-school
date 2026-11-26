import 'package:flutter/material.dart';
import '../models/clima.dart';
import '../services/clima_service.dart';
import '../theme/cores.dart';

/// Card de clima atual no ponto de embarque — usa a API gratuita Open-Meteo.
/// Fica em branco (SizedBox.shrink) se não houver coordenada ou se a API falhar,
/// pra nunca quebrar a tela em volta.
class CardClima extends StatefulWidget {
  final double? lat;
  final double? lng;

  const CardClima({super.key, this.lat, this.lng});

  @override
  State<CardClima> createState() => _CardClimaState();
}

class _CardClimaState extends State<CardClima> {
  Clima? _clima;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void didUpdateWidget(CardClima oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mudouDeVerdade(oldWidget.lat, widget.lat) || _mudouDeVerdade(oldWidget.lng, widget.lng)) {
      _carregar();
    }
  }

  // Ignora tremor de GPS: só considera "mudou de posição" quando anda mais
  // de ~1km. Sem isso, toda atualização de localização ao vivo (a cada
  // poucos metros) recarregava o clima de novo.
  bool _mudouDeVerdade(double? a, double? b) {
    if (a == null || b == null) return a != b;
    return (a - b).abs() > 0.01;
  }

  Future<void> _carregar() async {
    if (widget.lat == null || widget.lng == null) return;
    setState(() => _carregando = true);
    final clima = await ClimaService.instance.buscarClimaAtual(lat: widget.lat!, lng: widget.lng!);
    if (!mounted) return;
    setState(() {
      _clima = clima;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lat == null || widget.lng == null) return const SizedBox.shrink();

    if (_carregando && _clima == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppCores.superficie(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppCores.borda(context)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text('Carregando o clima...', style: TextStyle(fontSize: 12.5, color: AppCores.textoSecundario(context))),
          ],
        ),
      );
    }

    final clima = _clima;
    if (clima == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Row(
        children: [
          Text(clima.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${clima.temperatura.round()}°C — ${clima.descricao}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppCores.textoPrincipal(context)),
                ),
                if (clima.avisoChuva)
                  Text(
                    'Pode chover no horário da rota — combine um ponto coberto com os responsáveis.',
                    style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
