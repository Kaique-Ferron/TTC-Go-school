import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/card_filho.dart';
import '../../widgets/modal_info_filho.dart';
import '../../widgets/campos.dart';
import '../../widgets/botoes.dart';

class TelaMeusFilhos extends StatefulWidget {
  const TelaMeusFilhos({super.key});

  @override
  State<TelaMeusFilhos> createState() => _TelaMeusFilhosState();
}

class _TelaMeusFilhosState extends State<TelaMeusFilhos> {
  static const Color azulPrincipal = Color(0xFF1D58E2);

  final _formKey = GlobalKey<FormState>();
  bool _exibindoFormulario = false;
  bool _salvando = false;
  Filho? _filhoEmEdicao;

  final _nomeController = TextEditingController();
  final _idadeEAnoController = TextEditingController();
  final _escolaController = TextEditingController();
  final _turnoController = TextEditingController();
  final _horarioController = TextEditingController();
  final _tipoSanguineoController = TextEditingController();
  final _alergiasController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeEAnoController.dispose();
    _escolaController.dispose();
    _turnoController.dispose();
    _horarioController.dispose();
    _tipoSanguineoController.dispose();
    _alergiasController.dispose();
    super.dispose();
  }

  void _abrirFormularioNovo() {
    _filhoEmEdicao = null;
    _nomeController.clear();
    _idadeEAnoController.clear();
    _escolaController.clear();
    _turnoController.clear();
    _horarioController.clear();
    _tipoSanguineoController.clear();
    _alergiasController.clear();
    setState(() => _exibindoFormulario = true);
  }

  void _abrirFormularioEdicao(Filho filho) {
    _filhoEmEdicao = filho;
    _nomeController.text = filho.nome;
    _idadeEAnoController.text = filho.idadeEAno;
    _escolaController.text = filho.escola;
    _turnoController.text = filho.turno;
    _horarioController.text = filho.horario;
    _tipoSanguineoController.text = filho.tipoSanguineo;
    _alergiasController.text = filho.alergias;
    setState(() => _exibindoFormulario = true);
  }

  void _abrirModalDetalhes(String uid, Filho filho) {
    showDialog(
      context: context,
      builder: (dialogContext) => ModalInfoFilho(
        nome: filho.nome,
        idadeEAno: filho.idadeEAno,
        escola: filho.escola,
        periodo: '${filho.turno} (${filho.horario})',
        tipoSanguineo: filho.tipoSanguineo.isEmpty ? '—' : filho.tipoSanguineo,
        alergias: filho.alergias.isEmpty ? 'Nenhuma' : filho.alergias,
        status: filho.status,
        onEditar: () {
          Navigator.pop(dialogContext);
          _abrirFormularioEdicao(filho);
        },
        onExcluir: () async {
          Navigator.pop(dialogContext);
          if (filho.id == null) return;
          await FirestoreService.instance.excluirFilho(uid, filho.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil do filho removido!'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  Future<void> _salvarFilho(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final filho = Filho(
        id: _filhoEmEdicao?.id,
        nome: _nomeController.text.trim(),
        idadeEAno: _idadeEAnoController.text.trim(),
        escola: _escolaController.text.trim(),
        turno: _turnoController.text.trim(),
        horario: _horarioController.text.trim(),
        tipoSanguineo: _tipoSanguineoController.text.trim(),
        alergias: _alergiasController.text.trim(),
      );
      await FirestoreService.instance.salvarFilho(uid, filho);
      if (!mounted) return;
      setState(() => _exibindoFormulario = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_filhoEmEdicao == null ? 'Filho cadastrado com sucesso!' : 'Filho atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    // Guarda de sessão real (temporariamente desativada — login/cadastro
    // estão em modo de teste e não autenticam de verdade no Firebase):
    // final logado = context.watch<SessaoProvider>().logado;
    final uid = context.watch<SessaoProvider>().uidEfetivo;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meus Filhos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Meus filhos'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _exibindoFormulario ? _buildFormularioFilho(uid) : _buildListaFilhos(uid),
      ),
    );
  }

  // Lista dos filhos existentes
  Widget _buildListaFilhos(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gerencie as informações dos seus filhos para contratação de transporte.',
          style: TextStyle(color: Colors.grey, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        StreamBuilder<List<Filho>>(
          stream: FirestoreService.instance.filhosStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final filhos = snapshot.data ?? [];
            if (filhos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhum filho cadastrado ainda.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              );
            }
            return Column(
              children: filhos
                  .map(
                    (filho) => CardFilho(
                      nome: filho.nome,
                      idadeEAno: filho.idadeEAno,
                      escola: filho.escola,
                      turno: filho.turno,
                      horario: filho.horario,
                      status: filho.status,
                      onTap: () => _abrirModalDetalhes(uid, filho),
                    ),
                  )
                  .toList(),
            );
          },
        ),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: azulPrincipal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _abrirFormularioNovo,
          icon: const Icon(Icons.add, color: azulPrincipal),
          label: const Text('Cadastrar novo filho', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Formulário de Cadastro/Edição de Filho
  Widget _buildFormularioFilho(String uid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filhoEmEdicao == null ? 'Cadastrar Filho' : 'Editar Filho',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _exibindoFormulario = false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CampoTextoCustomizado(
              controller: _nomeController,
              hintText: 'Nome completo da criança',
              prefixIcon: Icons.person_outline,
              validator: _obrigatorio,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _idadeEAnoController,
              hintText: 'Idade / Série (ex: 9 anos • 4º ano)',
              prefixIcon: Icons.cake_outlined,
              validator: _obrigatorio,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _escolaController,
              hintText: 'Nome da Escola',
              prefixIcon: Icons.school_outlined,
              validator: _obrigatorio,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _turnoController,
              hintText: 'Turno / Período (ex: Manhã)',
              prefixIcon: Icons.schedule_outlined,
              validator: _obrigatorio,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _horarioController,
              hintText: 'Horário (ex: 07:00 - 12:00)',
              prefixIcon: Icons.access_time,
              validator: _obrigatorio,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _tipoSanguineoController,
              hintText: 'Tipo Sanguíneo (ex: O+)',
              prefixIcon: Icons.bloodtype_outlined,
            ),
            const SizedBox(height: 10),
            CampoTextoCustomizado(
              controller: _alergiasController,
              hintText: 'Alergias / Cuidados especiais',
              prefixIcon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 20),

            BotaoPrincipal(
              texto: 'Salvar Cadastro',
              cor: azulPrincipal,
              carregando: _salvando,
              onPressed: () => _salvarFilho(uid),
            ),
          ],
        ),
      ),
    );
  }
}
