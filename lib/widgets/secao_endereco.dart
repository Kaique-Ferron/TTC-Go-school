import 'package:flutter/material.dart';
import '../services/viacep_service.dart';
import 'campos.dart';

class SecaoEndereco extends StatefulWidget {
  final TextEditingController cepController;
  final TextEditingController ruaController;
  final TextEditingController numeroController;
  final TextEditingController bairroController;

  const SecaoEndereco({
    super.key,
    required this.cepController,
    required this.ruaController,
    required this.numeroController,
    required this.bairroController,
  });

  @override
  State<SecaoEndereco> createState() => _SecaoEnderecoState();
}

class _SecaoEnderecoState extends State<SecaoEndereco> {
  bool _carregandoCep = false;
  String? _erroCep;

  Future<void> _buscarEPreencherEndereco(String valor) async {
    final cepLimpo = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length == 8) {
      setState(() {
        _carregandoCep = true;
        _erroCep = null;
      });

      final endereco = await ViaCepService.buscarCep(cepLimpo);

      setState(() => _carregandoCep = false);

      if (endereco != null && !endereco.erro) {
        widget.ruaController.text = endereco.logradouro;
        widget.bairroController.text =
            '${endereco.bairro} - ${endereco.localidade}/${endereco.uf}';
      } else {
        setState(() {
          _erroCep = 'CEP não encontrado. Digite um CEP válido.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Endereço',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),

        // Campo CEP com indicador visual de busca
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFAFBFCF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: widget.cepController,
            keyboardType: TextInputType.number,
            maxLength: 9,
            onChanged: _buscarEPreencherEndereco,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'CEP (ex: 01310-100)',
              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
              suffixIcon: _carregandoCep
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),

        if (_erroCep != null) ...[
          const SizedBox(height: 4),
          Text(_erroCep!, style: const TextStyle(color: Colors.red, fontSize: 11)),
        ],

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: CampoTextoCustomizado(
                controller: widget.ruaController,
                hintText: 'Rua / Avenida',
                prefixIcon: Icons.map_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: CampoTextoCustomizado(
                controller: widget.numeroController,
                hintText: 'Nº',
                prefixIcon: Icons.home_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        CampoTextoCustomizado(
          controller: widget.bairroController,
          hintText: 'Bairro / Cidade',
          prefixIcon: Icons.location_city_outlined,
        ),
      ],
    );
  }
}