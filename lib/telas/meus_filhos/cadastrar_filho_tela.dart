import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/filho.dart';
import '../../theme/cores.dart';
import '../../widgets/seletor_turno.dart';
import '../../widgets/secao_endereco_form.dart';
import '../../widgets/navbar_responsavel.dart';

class CadastrarFilhoTela extends StatefulWidget {
  final Filho? filhoParaEditar;

  const CadastrarFilhoTela({super.key, this.filhoParaEditar});

  @override
  State<CadastrarFilhoTela> createState() => _CadastrarFilhoTelaState();
}

class _CadastrarFilhoTelaState extends State<CadastrarFilhoTela> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _apelidoController;
  late TextEditingController _idadeEAnoController;
  late TextEditingController _escolaController;
  late TextEditingController _horarioInicioController;
  late TextEditingController _horarioFimController;
  late TextEditingController _tipoSanguineoController;
  late TextEditingController _alergiasController;

  // Controllers de Endereço
  late TextEditingController _cepController;
  late TextEditingController _enderecoController;
  late TextEditingController _numeroController;
  late TextEditingController _bairroController;
  late TextEditingController _cidadeUfController;

  String _turnoSelecionado = 'Manhã';
  bool _mesmoEnderecoResponsavel = true;
  bool _salvando = false;
  double? _casaLat;
  double? _casaLng;

  final List<String> _escolasSugeridas = [
    'ETEC Albert Einstein',
    'Colégio Objetivo',
    'Escola Estadual Professor Camargo',
    'Colégio Pentágono',
    'Colégio Bandeirantes',
    'Colégio Santa Cruz',
    'SENAI Suíço-Brasileira',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.filhoParaEditar;

    _nomeController = TextEditingController(text: f?.nome ?? '');
    _apelidoController = TextEditingController();
    _idadeEAnoController = TextEditingController(text: f?.idadeEAno ?? '');
    _escolaController = TextEditingController(text: f?.escola ?? '');

    List<String> horarSplit = (f?.horario ?? '').split('-');
    _horarioInicioController = TextEditingController(
      text: horarSplit.isNotEmpty ? horarSplit[0].trim() : '07:00',
    );
    _horarioFimController = TextEditingController(
      text: horarSplit.length > 1 ? horarSplit[1].trim() : '12:00',
    );

    _tipoSanguineoController = TextEditingController(text: f?.tipoSanguineo ?? '');
    _alergiasController = TextEditingController(text: f?.alergias ?? '');

    if (f != null && f.turno.isNotEmpty) {
      _turnoSelecionado = f.turno;
    }

    _cepController = TextEditingController();
    _enderecoController = TextEditingController();
    _numeroController = TextEditingController();
    _bairroController = TextEditingController();
    _cidadeUfController = TextEditingController();

    if (f == null) {
      _carregarEnderecoResponsavel();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    _idadeEAnoController.dispose();
    _escolaController.dispose();
    _horarioInicioController.dispose();
    _horarioFimController.dispose();
    _tipoSanguineoController.dispose();
    _alergiasController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeUfController.dispose();
    super.dispose();
  }

  Future<void> _carregarEnderecoResponsavel() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final dados = doc.data();

    if (dados != null && mounted) {
      setState(() {
        _cepController.text = dados['cep'] ?? '';
        _enderecoController.text = dados['endereco'] ?? '';
        _numeroController.text = dados['numero'] ?? '';
        _bairroController.text = dados['bairro'] ?? '';
        _cidadeUfController.text = dados['cidade_uf'] ?? '';
        _casaLat = (dados['casa_lat'] as num?)?.toDouble();
        _casaLng = (dados['casa_lng'] as num?)?.toDouble();
      });
    }
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (hora != null && mounted) {
      final horaFormatada =
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = horaFormatada;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => _salvando = false);
      return;
    }

    final horarioFormatado =
        '${_horarioInicioController.text.trim()} - ${_horarioFimController.text.trim()}';

    final novoFilho = Filho(
      id: widget.filhoParaEditar?.id,
      nome: _nomeController.text.trim(),
      idadeEAno: _idadeEAnoController.text.trim(),
      escola: _escolaController.text.trim(),
      turno: _turnoSelecionado,
      horario: horarioFormatado,
      tipoSanguineo: _tipoSanguineoController.text.trim(),
      alergias: _alergiasController.text.trim(),
      status: widget.filhoParaEditar?.status ?? 'Ativo',
    );

    try {
      final colecaoFilhos = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('filhos');

      final dadosParaSalvar = novoFilho.toMap();
      dadosParaSalvar.addAll({
        'apelido': _apelidoController.text.trim(),
        'cep': _cepController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'numero': _numeroController.text.trim(),
        'bairro': _bairroController.text.trim(),
        'cidade_uf': _cidadeUfController.text.trim(),
        'casa_lat': _casaLat,
        'casa_lng': _casaLng,
      });

      if (widget.filhoParaEditar == null) {
        await colecaoFilhos.add(dadosParaSalvar);
      } else {
        if (widget.filhoParaEditar!.id != null) {
          await colecaoFilhos.doc(widget.filhoParaEditar!.id).update(dadosParaSalvar);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.filhoParaEditar == null
                  ? 'Filho cadastrado com sucesso!'
                  : 'Informações do filho atualizadas!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdicao = widget.filhoParaEditar != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdicao ? 'Editar Filho' : 'Cadastrar Filho'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Dados Pessoais
              _buildBlocoWrapper(
                titulo: 'Dados Pessoais',
                icone: Icons.child_care_outlined,
                corIcone: AppCores.azulPrincipal,
                children: [
                  _buildCampoTexto(
                    controller: _nomeController,
                    label: 'Nome Completo',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildCampoTexto(
                    controller: _apelidoController,
                    label: 'Apelido (Opcional)',
                    icon: Icons.face_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildCampoTexto(
                    controller: _idadeEAnoController,
                    label: 'Idade e Ano Escolar (ex: 9 anos • 4º ano)',
                    icon: Icons.cake_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Informe a idade/ano' : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Informações Escolares com Autocomplete e SeletorTurno
              _buildBlocoWrapper(
                titulo: 'Informações Escolares',
                icone: Icons.school_outlined,
                corIcone: AppCores.roxo,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _escolasSugeridas.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    initialValue: TextEditingValue(text: _escolaController.text),
                    onSelected: (String selection) {
                      _escolaController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      _escolaController = controller;
                      return _buildCampoTexto(
                        controller: controller,
                        label: 'Nome da Escola',
                        icon: Icons.school_outlined,
                        focusNode: focusNode,
                        validator: (v) => v == null || v.isEmpty ? 'Informe a escola' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Widget Modular para Seleção de Turno
                  SeletorTurno(
                    turnoSelecionado: _turnoSelecionado,
                    onTurnoSelecionado: (novoTurno) {
                      setState(() => _turnoSelecionado = novoTurno);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Seleção de Horários com TimePicker
                  Row(
                    children: [
                      Expanded(
                        child: _buildCampoTexto(
                          controller: _horarioInicioController,
                          label: 'Horário Entrada',
                          icon: Icons.access_time,
                          readOnly: true,
                          onTap: () => _selecionarHora(_horarioInicioController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCampoTexto(
                          controller: _horarioFimController,
                          label: 'Horário Saída',
                          icon: Icons.access_time_filled_outlined,
                          readOnly: true,
                          onTap: () => _selecionarHora(_horarioFimController),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Endereço da Criança com Componente SecaoEnderecoForm
              _buildBlocoWrapper(
                titulo: 'Endereço de Embarque / Casa',
                icone: Icons.home_outlined,
                corIcone: AppCores.laranjaMotorista,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Mesmo endereço do responsável',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    value: _mesmoEnderecoResponsavel,
                    activeColor: AppCores.azulPrincipal,
                    onChanged: (val) {
                      setState(() {
                        _mesmoEnderecoResponsavel = val;
                        if (val) _carregarEnderecoResponsavel();
                      });
                    },
                  ),
                  if (!_mesmoEnderecoResponsavel)
                    SecaoEnderecoForm(
                      cepController: _cepController,
                      enderecoController: _enderecoController,
                      numeroController: _numeroController,
                      bairroController: _bairroController,
                      cidadeUfController: _cidadeUfController,
                      casaLat: _casaLat,
                      casaLng: _casaLng,
                      onCoordenadasAlteradas: (coords) {
                        setState(() {
                          _casaLat = coords['lat'];
                          _casaLng = coords['lng'];
                        });
                      },
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // 4. Saúde e Observações
              _buildBlocoWrapper(
                titulo: 'Saúde e Observações (Opcional)',
                icone: Icons.health_and_safety_outlined,
                corIcone: AppCores.verde,
                children: [
                  _buildCampoTexto(
                    controller: _tipoSanguineoController,
                    label: 'Tipo Sanguíneo (ex: O+)',
                    icon: Icons.bloodtype_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildCampoTexto(
                    controller: _alergiasController,
                    label: 'Alergias ou Observações de Saúde',
                    icon: Icons.warning_amber_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Botão de Gravar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
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
                      : const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    _salvando ? 'Salvando...' : (isEdicao ? 'Salvar Alterações' : 'Cadastrar Filho'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlocoWrapper({
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
    FocusNode? focusNode,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
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