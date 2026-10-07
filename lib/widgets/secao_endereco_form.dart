import 'package:flutter/material.dart';
import '../models/endereco.dart';
import '../services/viacep_service.dart';
import '../theme/cores.dart';
import '../telas/meu_perfil/mapa_casa_tela.dart';

class SecaoEnderecoForm extends StatefulWidget {
  final TextEditingController cepController;
  final TextEditingController enderecoController;
  final TextEditingController numeroController;
  final TextEditingController bairroController;
  final TextEditingController cidadeUfController;
  final double? casaLat;
  final double? casaLng;
  final ValueChanged<Map<String, double>> onCoordenadasAlteradas;

  const SecaoEnderecoForm({
    super.key,
    required this.cepController,
    required this.enderecoController,
    required this.numeroController,
    required this.bairroController,
    required this.cidadeUfController,
    this.casaLat,
    this.casaLng,
    required this.onCoordenadasAlteradas,
  });

  @override
  State<SecaoEnderecoForm> createState() => _SecaoEnderecoFormState();
}

class _SecaoEnderecoFormState extends State<SecaoEnderecoForm> {
  bool _buscandoCep = false;

  Future<void> _buscarCep() async {
    final cep = widget.cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;

    setState(() => _buscandoCep = true);
    try {
      final Endereco? endereco = await ViaCepService.buscarCep(cep);
      if (endereco != null && mounted) {
        setState(() {
          widget.enderecoController.text = endereco.logradouro ?? '';
          widget.bairroController.text = endereco.bairro ?? '';
          widget.cidadeUfController.text = '${endereco.localidade} - ${endereco.uf}';
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar CEP. Verifique o número.')),
        );
      }
    } finally {
      if (mounted) setState(() => _buscandoCep = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInput(
                controller: widget.cepController,
                label: 'CEP',
                icon: Icons.map_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => _buscarCep(),
              ),
            ),
            if (_buscandoCep) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildInput(
                controller: widget.enderecoController,
                label: 'Rua / Logradouro',
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildInput(
                controller: widget.numeroController,
                label: 'Nº',
                icon: Icons.numbers,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildInput(
                controller: widget.bairroController,
                label: 'Bairro',
                icon: Icons.holiday_village_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInput(
                controller: widget.cidadeUfController,
                label: 'Cidade - UF',
                icon: Icons.location_on_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.my_location, color: AppCores.azulPrincipal),
          title: Text(
            widget.casaLat != null
                ? 'Localização marcada no mapa'
                : 'Marcar localização no mapa',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapaCasaTela(
                  latitudeAtual: widget.casaLat,
                  longitudeAtual: widget.casaLng,
                ),
              ),
            );
            if (res is Map<String, double>) {
              widget.onCoordenadasAlteradas(res);
            }
          },
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}