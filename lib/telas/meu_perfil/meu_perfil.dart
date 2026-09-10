import 'package:flutter/material.dart';
import '../../widgets/navbar_responsavel.dart';
import '../../widgets/card_filho.dart';
import '../../widgets/card_cartao.dart';
import '../../widgets/modal_info_filho.dart'; // 1. IMPORT ADICIONADO

class TelaMeuPerfil extends StatelessWidget {
  const TelaMeuPerfil({super.key});

  static const Color azulPrincipal = Color(0xFF1D58E2);

  // 2. FUNÇÃO ADICIONADA PARA ABRIR O MODAL DE DETALHES
  void _abrirModalDetalhes(
    BuildContext context, {
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
          Navigator.pushNamed(context, '/meus-filhos');
        },
        onExcluir: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil do filho removido!'),
              backgroundColor: Colors.red,
            ),
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
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Meu Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerencie suas informações e preferências.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Card Dados Pessoais
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFE8F0FE),
                        child: Icon(Icons.person, size: 48, color: azulPrincipal),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Marcos Silva',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Responsável Principal',
                          style: TextStyle(color: azulPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildItemInfo(Icons.email_outlined, 'marcos.silva@email.com'),
                  const SizedBox(height: 8),
                  _buildItemInfo(Icons.phone_outlined, '(11) 98765-4321'),
                  const SizedBox(height: 8),
                  _buildItemInfo(Icons.location_on_outlined, 'São Paulo, SP'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Meus Filhos
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Meus filhos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          // 3. NAVEGAÇÃO PARA A TELA MEUS FILHOS
                          Navigator.pushNamed(context, '/meus-filhos');
                        },
                        child: const Text('Ver todos', style: TextStyle(color: azulPrincipal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // CARDS CONECTADOS AO MODAL VIA onTap
                  CardFilho(
                    nome: 'João Silva',
                    idadeEAno: '9 anos • 4º ano',
                    escola: 'ETEC Albert Einstein',
                    turno: 'Manhã',
                    horario: '07:00 - 12:00',
                    onTap: () => _abrirModalDetalhes(
                      context,
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
                      context,
                      nome: 'Maria Silva',
                      idadeEAno: '12 anos • 7º ano',
                      escola: 'Colégio Objetivo',
                      periodo: 'Tarde (13:00 - 18:00)',
                      tipoSanguineo: 'A+',
                      alergias: 'Poeira, Lactose',
                    ),
                  ),
                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      side: const BorderSide(color: azulPrincipal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // 3. NAVEGAÇÃO PARA A TELA MEUS FILHOS (CADASTRAR NOVO)
                      Navigator.pushNamed(context, '/meus-filhos');
                    },
                    icon: const Icon(Icons.add, color: azulPrincipal),
                    label: const Text('Adicionar filho', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Método de Pagamento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Método de pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Editar', style: TextStyle(color: azulPrincipal)),
                      ),
                    ],
                  ),
                  Text('Gerencie seu método de pagamento.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 16),
                  const CardCartao(
                    ultimosDigitos: '1234',
                    validade: '08/28',
                    titular: 'Marcos Silva',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      side: const BorderSide(color: azulPrincipal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: azulPrincipal),
                    label: const Text('Adicionar cartão', style: TextStyle(color: azulPrincipal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(texto, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
}