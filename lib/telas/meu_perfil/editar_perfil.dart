import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/viacep_service.dart';
import '../../theme/cores.dart';
import 'mapa_casa_tela.dart';
import '../../models/endereco.dart';

class EditarPerfilTela extends StatefulWidget {
  final Map<String, dynamic>? dadosAtuais;

  const EditarPerfilTela({super.key, this.dadosAtuais});

  @override
  State<EditarPerfilTela> createState() => _EditarPerfilTelaState();
}

class _EditarPerfilTelaState extends State<EditarPerfilTela> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cepController;
  late TextEditingController _enderecoController;
  late TextEditingController _numeroController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeUfController;

  bool _salvando = false;
  bool _buscandoCep = false;
  double? _casaLat;
  double? _casaLng;

  @override
  void initState() {
    super.initState();
    final d = widget.dadosAtuais;

    _nomeController = TextEditingController(text: d?['nome'] ?? '');
    _emailController = TextEditingController(
      text: d?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '',
    );
    _telefoneController = TextEditingController(text: d?['telefone'] ?? '');
    _cepController = TextEditingController(text: d?['cep'] ?? '');
    _enderecoController = TextEditingController(text: d?['endereco'] ?? '');
    _numeroController = TextEditingController(text: d?['numero'] ?? '');
    _bairroController = TextEditingController(text: d?['bairro'] ?? '');
    _cidadeUfController = TextEditingController(text: d?['cidade_uf'] ?? '');

    _casaLat = (d?['casa_lat'] as num?)?.toDouble();
    _casaLng = (d?['casa_lng'] as num?)?.toDouble();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeUfController.dispose();
    super.dispose();
  }

Future<void> _buscarCep() async {
  final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
  if (cep.length != 8) return;

  setState(() => _buscandoCep = true);
  try {
    // 1. Chama o método estático correto da sua classe
    final Endereco? endereco = await ViaCepService.buscarCep(cep);

    if (endereco != null && mounted) {
      setState(() {
        // 2. Acessa as propriedades do modelo Endereco diretamente
        _enderecoController.text = endereco.logradouro ?? '';
        _bairroController.text = endereco.bairro ?? '';
        _cidadeUfController.text = '${endereco.localidade} - ${endereco.uf}';
      });
    }
  } catch (_) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao buscar CEP. Verifique o número digitado.'),
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _buscandoCep = false);
  }
}
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => _salvando = false);
      return;
    }

    try {
      // 1. Se o e-mail mudou, atualiza na autenticação do Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      // 2. Atualiza os dados cadastrais no documento do Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'cep': _cepController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'numero': _numeroController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'cidade_uf': _cidadeUfController.text.trim(),
        'casa_lat': _casaLat,
        'casa_lng': _casaLng,
        'ultima_atualizacao': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alterações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Editar Cadastro e Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEÇÃO 1: DADOS PESSOAIS ---
              _buildBlocoFormulario(
                titulo: 'Dados Pessoais',
                icone: Icons.person_outline,
                corIcone: AppCores.azulPrincipal,
                children: [
                  _buildCampoTexto(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    icon: Icons.person,
                    validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildCampoTexto(
                    controller: _emailController,
                    label: 'E-mail de Contato',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@') ? 'Informe um e-mail válido' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildCampoTexto(
                    controller: _telefoneController,
                    label: 'Telefone / WhatsApp',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- SEÇÃO 2: ENDEREÇO RESIDENCIAL ---
              _buildBlocoFormulario(
                titulo: 'Endereço Residencial',
                icone: Icons.home_outlined,
                corIcone: AppCores.laranjaMotorista,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCampoTexto(
                          controller: _cepController,
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
                        child: _buildCampoTexto(
                          controller: _enderecoController,
                          label: 'Logradouro / Rua',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildCampoTexto(
                          controller: _numeroController,
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
                        child: _buildCampoTexto(
                          controller: _bairroController,
                          label: 'Bairro',
                          icon: Icons.holiday_village_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCampoTexto(
                          controller: _cidadeUfController,
                          label: 'Cidade - UF',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- SEÇÃO 3: PONTO NO MAPA ---
              _buildBlocoFormulario(
                titulo: 'Ponto no Mapa para o Transporte',
                icone: Icons.pin_drop_outlined,
                corIcone: AppCores.ciano,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.my_location, color: AppCores.azulPrincipal),
                    title: Text(
                      _casaLat != null
                          ? 'Localização marcada no mapa'
                          : 'Nenhuma localização exata salva',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Toque para ajustar a posição da sua casa no mapa',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapaCasaTela(
                            latitudeAtual: _casaLat,
                            longitudeAtual: _casaLng,
                          ),
                        ),
                      );
                      if (resultado is Map<String, double>) {
                        setState(() {
                          _casaLat = resultado['lat'];
                          _casaLng = resultado['lng'];
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- BOTÃO DE SALVAR ALTERAÇÕES ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvarAlteracoes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppCores.azulPrincipal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _salvando ? 'Salvando...' : 'Salvar Alterações',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlocoFormulario({
    required String titulo,
    required IconData icone,
    required Color corIcone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 16, color: corIcone),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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