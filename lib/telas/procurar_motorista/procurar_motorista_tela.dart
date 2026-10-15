import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../theme/cores.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/nav_inferior_responsavel.dart';
import '../../widgets/card_motorista.dart';
import '../../widgets/banner_boas_vindas.dart';
import '../../widgets/card_passos_cadastro.dart';
import '../meus_filhos/cadastrar_filho_tela.dart';

class ProcurarMotoristaTela extends StatefulWidget {
  const ProcurarMotoristaTela({super.key});

  @override
  State<ProcurarMotoristaTela> createState() => _ProcurarMotoristaTelaState();
}

class _ProcurarMotoristaTelaState extends State<ProcurarMotoristaTela> {
  final TextEditingController _buscaController = TextEditingController();
  String _cidadeSelecionada = 'São Paulo, SP';

  // Lista simulada de motoristas baseada no layout
  final List<MotoristaModel> _motoristas = const [
    MotoristaModel(
      id: '1',
      nome: 'Carlos Silva',
      avaliacao: 4.9,
      totalAvaliacoes: 128,
      veiculo: 'Van Escolar - Renault Master',
      escolasAtendidas: ['ETEC Albert Einstein', 'Colégio Objetivo'],
      vagasDisponiveis: 8,
    ),
    MotoristaModel(
      id: '2',
      nome: 'Ricardo Lima',
      avaliacao: 4.8,
      totalAvaliacoes: 96,
      veiculo: 'Van Escolar - Fiat Ducato',
      escolasAtendidas: ['Colégio Batista', 'ETEC Zona Leste'],
      vagasDisponiveis: 5,
    ),
    MotoristaModel(
      id: '3',
      nome: 'Fernanda Costa',
      avaliacao: 4.9,
      totalAvaliacoes: 74,
      veiculo: 'Micro-ônibus - Volare V8',
      escolasAtendidas: ['Colégio Ágape', 'Objetivo Morumbi'],
      vagasDisponiveis: 6,
    ),
    MotoristaModel(
      id: '4',
      nome: 'João Santos',
      avaliacao: 4.7,
      totalAvaliacoes: 60,
      veiculo: 'Van Escolar - Mercedes Sprinter',
      escolasAtendidas: ['ETEC Albert Einstein', 'Colégio Integração'],
      vagasDisponiveis: 7,
    ),
    MotoristaModel(
      id: '5',
      nome: 'Paulo Henrique',
      avaliacao: 4.8,
      totalAvaliacoes: 112,
      veiculo: 'Van Escolar - Renault Master',
      escolasAtendidas: ['Colégio Objetivo', 'ETEC Zona Leste'],
      vagasDisponiveis: 4,
    ),
    MotoristaModel(
      id: '6',
      nome: 'Juliana Alves',
      avaliacao: 4.9,
      totalAvaliacoes: 88,
      veiculo: 'Micro-ônibus - Volare Fly 10',
      escolasAtendidas: ['Colégio Batista', 'Colégio Ágape'],
      vagasDisponiveis: 3,
    ),
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirCadastrarFilho() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastrarFilhoTela()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    if (!logado) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: const Text('Sessão expirada. Toque para fazer login novamente.'),
          ),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Procurar Motorista'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Procurar Motorista'),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Motoristas'),
      body: StreamBuilder<List<Filho>>(
        stream: FirestoreService.instance.filhosStream(uid),
        builder: (context, snapshotFilhos) {
          final int totalFilhos = snapshotFilhos.data?.length ?? 0;
          final bool temFilhos = totalFilhos > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Superior
                BannerBoasVindas(
                  temFilhos: temFilhos,
                  onCadastrarFilho: _abrirCadastrarFilho,
                ),
                if (!temFilhos) const SizedBox(height: 20),

                // Grid Responsivo de Conteúdo
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 950;

                    return Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- COLUNA PRINCIPAL: MOTORISTAS ---
                        Expanded(
                          flex: isWide ? 3 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título e Seletor de Cidade
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Encontre um motorista',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Veja motoristas disponíveis na sua região e solicite uma vaga.',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: AppCores.azulPrincipal),
                                        const SizedBox(width: 4),
                                        Text(_cidadeSelecionada, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        const Icon(Icons.arrow_drop_down, size: 18),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Campo de Pesquisa e Filtros
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _buscaController,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Pesquisar por nome, escola ou bairro...',
                                        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade600),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.tune, size: 16, color: Colors.black87),
                                    label: const Text('Filtros', style: TextStyle(color: Colors.black87, fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Cards dos Motoristas em Grid
                              LayoutBuilder(
                                builder: (context, gridConstraints) {
                                  int columns = gridConstraints.maxWidth > 650 ? 2 : 1;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      mainAxisExtent: 280,
                                    ),
                                    itemCount: _motoristas.length,
                                    itemBuilder: (context, index) {
                                      final motorista = _motoristas[index];
                                      return CardMotorista(
                                        motorista: motorista,
                                        temFilhoCadastrado: temFilhos,
                                        onSolicitarVaga: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Solicitação enviada para ${motorista.nome}!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  '🛡️ Todos os motoristas são verificados e passam por um rigoroso processo de segurança.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isWide) const SizedBox(width: 20),
                        if (!isWide) const SizedBox(height: 20),

                        // --- COLUNA LATERAL: PASSO A PASSO ---
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: CardPassosCadastro(
                            temFilhos: temFilhos,
                            onVerFilhos: () => Navigator.pushNamed(context, '/meus-filhos'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}