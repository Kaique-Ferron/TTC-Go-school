import 'package:flutter/material.dart';
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
  bool _exibindoFormulario = false;

  void _abrirModalDetalhes({
    required String nome,
    required String idadeEAno,
    required String escola,
    required String periodo,
    required String tipoSanguineo,
    required String alergias,
  }) {
    showDialog(
      context: context,
      builder: (context) => ModalInfoFilho(
        nome: nome,
        idadeEAno: idadeEAno,
        escola: escola,
        periodo: periodo,
        tipoSanguineo: tipoSanguineo,
        alergias: alergias,
        onEditar: () {
          Navigator.pop(context);
          setState(() => _exibindoFormulario = true);
        },
        onExcluir: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil do filho removido!'), backgroundColor: Colors.red),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: _exibindoFormulario ? _buildFormularioNovoFilho() : _buildListaFilhos(),
      ),
    );
  }

  // Lista dos filhos existentes
  Widget _buildListaFilhos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gerencie as informações dos seus filhos para contratação de transporte.',
          style: TextStyle(color: Colors.grey, fontSize: 13.5),
        ),
        const SizedBox(height: 20),

        CardFilho(
          nome: 'João Silva',
          idadeEAno: '9 anos • 4º ano',
          escola: 'ETEC Albert Einstein',
          turno: 'Manhã',
          horario: '07:00 - 12:00',
          onTap: () => _abrirModalDetalhes(
            nome: 'João Silva',
            idadeEAno: '9 anos • 4º ano',
            escola: 'ETEC Albert Einstein',
            periodo: 'Manhã (07:00 - 12:00)',
            tipoSanguineo: 'O+',
            alergias: 'Nenhuma',
          ),
        ),

        CardFilho(
          nome: 'Maria Silva',
          idadeEAno: '12 anos • 7º ano',
          escola: 'Colégio Objetivo',
          turno: 'Tarde',
          horario: '13:00 - 18:00',
          onTap: () => _abrirModalDetalhes(
            nome: 'Maria Silva',
            idadeEAno: '12 anos • 7º ano',
            escola: 'Colégio Objetivo',
            periodo: 'Tarde (13:00 - 18:00)',
            tipoSanguineo: 'A+',
            alergias: 'Poeira, Lactose',
          ),
        ),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: azulPrincipal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => setState(() => _exibindoFormulario = true),
          icon: const Icon(Icons.add, color: azulPrincipal),
          label: const Text('Cadastrar novo filho', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Formulário de Cadastro de Filho
  Widget _buildFormularioNovoFilho() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cadastrar Filho', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => setState(() => _exibindoFormulario = false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const CampoTextoCustomizado(hintText: 'Nome completo da criança', prefixIcon: Icons.person_outline),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Idade / Data de Nascimento', prefixIcon: Icons.cake_outlined),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Nome da Escola', prefixIcon: Icons.school_outlined),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Série / Ano', prefixIcon: Icons.class_outlined),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Turno / Período (ex: Manhã)', prefixIcon: Icons.schedule_outlined),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Tipo Sanguíneo (ex: O+)', prefixIcon: Icons.bloodtype_outlined),
          const SizedBox(height: 10),
          const CampoTextoCustomizado(hintText: 'Alergias / Cuidados especiais', prefixIcon: Icons.medical_services_outlined),
          const SizedBox(height: 20),

          BotaoPrincipal(
            texto: 'Salvar Cadastro',
            cor: azulPrincipal,
            onPressed: () {
              setState(() => _exibindoFormulario = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filho cadastrado com sucesso!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }
}