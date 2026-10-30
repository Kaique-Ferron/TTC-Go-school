import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filho.dart';
import '../../models/motorista_model.dart';
import '../../services/firestore_service.dart';
import '../../services/sessao_provider.dart';
import '../../theme/cores.dart';
import '../../widgets/modal_detalhes_motorista.dart';
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
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirDetalhes(Motorista motorista) {
    showDialog(
      context: context,
      builder: (_) => ModalDetalhesMotorista(motorista: motorista),
    );
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
        backgroundColor: AppCores.fundo(context),
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
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Procurar Motorista'),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Encontre um motorista',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Veja motoristas disponíveis na sua região e solicite uma vaga.',
                                          style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppCores.superficie(context),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppCores.borda(context)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppCores.azulPrincipal.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
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
                                      onChanged: (valor) => setState(() => _busca = valor.trim().toLowerCase()),
                                      style: TextStyle(fontSize: 13, color: AppCores.textoPrincipal(context)),
                                      decoration: InputDecoration(
                                        hintText: 'Pesquisar por nome...',
                                        prefixIcon: Icon(Icons.search, size: 18, color: AppCores.textoSecundario(context)),
                                        filled: true,
                                        fillColor: AppCores.superficie(context),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppCores.borda(context)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppCores.borda(context)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: AppCores.superficie(context),
                                      side: BorderSide(color: AppCores.borda(context)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    icon: Icon(Icons.tune, size: 16, color: AppCores.textoPrincipal(context)),
                                    label: Text('Filtros', style: TextStyle(color: AppCores.textoPrincipal(context), fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Cards dos Motoristas em Grid — dados reais do Firestore
                              // (mesma fonte usada na aba Serviços).
                              StreamBuilder<List<Motorista>>(
                                stream: FirestoreService.instance.motoristasStream(),
                                builder: (context, snapshotMotoristas) {
                                  if (snapshotMotoristas.connectionState == ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 40),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  final todos = snapshotMotoristas.data ?? [];
                                  final motoristas = _busca.isEmpty
                                      ? todos
                                      : todos.where((m) => m.nome.toLowerCase().contains(_busca)).toList();

                                  if (motoristas.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40),
                                      child: Center(
                                        child: Text(
                                          todos.isEmpty ? 'Nenhum motorista cadastrado ainda.' : 'Nenhum motorista encontrado pra "$_busca".',
                                          style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 13),
                                        ),
                                      ),
                                    );
                                  }

                                  return LayoutBuilder(
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
                                        itemCount: motoristas.length,
                                        itemBuilder: (context, index) {
                                          final motorista = motoristas[index];
                                          return CardMotorista(
                                            motorista: motorista,
                                            temFilhoCadastrado: temFilhos,
                                            onVerDetalhes: () => _abrirDetalhes(motorista),
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
                                  style: TextStyle(fontSize: 11, color: AppCores.textoSecundario(context)),
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