import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/sessao_provider.dart';
import '../../../theme/cores.dart';
import '../../../widgets/navbar_responsavel.dart';
import '../../../widgets/nav_inferior_responsavel.dart';

class ConfiguracoesTela extends StatefulWidget {
  const ConfiguracoesTela({super.key});

  @override
  State<ConfiguracoesTela> createState() => _ConfiguracoesTelaState();
}

class _ConfiguracoesTelaState extends State<ConfiguracoesTela> {
  // Aparência
  String _temaSelecionado = 'Escuro';
  String _tamanhoFonte = 'Média';

  // Notificações
  bool _notifPush = true;
  bool _notifEmbarque = true;
  bool _notifMensagens = true;
  bool _notifLembretesPagamento = true;
  bool _notifPromocoes = false;

  // Privacidade e Localização
  bool _autenticacaoDuasEtapas = false;
  bool _compartilharLocalizacaoRota = true;
  bool _permitirGpsApenasUso = true;

  bool _salvando = false;

  Future<void> _salvarAlteracoes() async {
    setState(() => _salvando = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const NavbarResponsavel(itemSelecionado: 'Configurações'),
      bottomNavigationBar: const NavInferiorResponsavel(abaSelecionada: 'Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalize sua experiência no GoSchool.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // 1. APARÊNCIA
            _buildBloco(
              titulo: '1. Aparência',
              icone: Icons.palette_outlined,
              children: [
                const Text('Tema', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSeletorTresOpcoes(
                  opcoes: ['Claro', 'Escuro', 'Automático'],
                  selecionado: _temaSelecionado,
                  onSelect: (v) => setState(() => _temaSelecionado = v),
                ),
                const SizedBox(height: 16),
                const Text('Tamanho da fonte', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSeletorTresOpcoes(
                  opcoes: ['Pequena', 'Média', 'Grande'],
                  selecionado: _tamanhoFonte,
                  onSelect: (v) => setState(() => _tamanhoFonte = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. NOTIFICAÇÕES
            _buildBloco(
              titulo: '2. Notificações',
              icone: Icons.notifications_none_outlined,
              children: [
                _buildSwitch(
                  icone: Icons.notifications_active_outlined,
                  titulo: 'Receber notificações push',
                  subtitulo: 'Fique por dentro de tudo em tempo real.',
                  valor: _notifPush,
                  onChanged: (v) => setState(() => _notifPush = v),
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.directions_bus_outlined,
                  titulo: 'Embarque e desembarque do filho',
                  subtitulo: 'Seja avisado quando seu filho embarcar ou desembarcar.',
                  valor: _notifEmbarque,
                  onChanged: (v) => setState(() => _notifEmbarque = v),
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.chat_outlined,
                  titulo: 'Mensagens do motorista',
                  subtitulo: 'Receber novas mensagens e respostas.',
                  valor: _notifMensagens,
                  onChanged: (v) => setState(() => _notifMensagens = v),
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.calendar_today_outlined,
                  titulo: 'Lembretes de pagamento',
                  subtitulo: 'Avisos sobre vencimento e confirmações.',
                  valor: _notifLembretesPagamento,
                  onChanged: (v) => setState(() => _notifLembretesPagamento = v),
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.tune_outlined,
                  titulo: 'Promoções e novidades',
                  subtitulo: 'Receber ofertas e novidades do GoSchool.',
                  valor: _notifPromocoes,
                  onChanged: (v) => setState(() => _notifPromocoes = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. PRIVACIDADE E SEGURANÇA
            _buildBloco(
              titulo: '3. Privacidade e Segurança',
              icone: Icons.shield_outlined,
              children: [
                _buildLink(
                  icone: Icons.lock_outline,
                  titulo: 'Alterar senha',
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.verified_user_outlined,
                  titulo: 'Autenticação em duas etapas',
                  subtitulo: 'Mais segurança para sua conta.',
                  valor: _autenticacaoDuasEtapas,
                  onChanged: (v) => setState(() => _autenticacaoDuasEtapas = v),
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.devices_outlined,
                  titulo: 'Gerenciar dispositivos conectados',
                  subtitulo: 'Veja e remova dispositivos conectados à sua conta.',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.privacy_tip_outlined,
                  titulo: 'Política de privacidade',
                  subtitulo: 'Saiba como protegemos seus dados.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. LOCALIZAÇÃO
            _buildBloco(
              titulo: '4. Localização',
              icone: Icons.location_on_outlined,
              children: [
                _buildSwitch(
                  icone: Icons.my_location_outlined,
                  titulo: 'Compartilhar localização durante a rota',
                  subtitulo: 'Permite que o motorista veja a localização do seu filho.',
                  valor: _compartilharLocalizacaoRota,
                  onChanged: (v) => setState(() => _compartilharLocalizacaoRota = v),
                ),
                const Divider(height: 1),
                _buildSwitch(
                  icone: Icons.gps_fixed_outlined,
                  titulo: 'Permitir acesso ao GPS apenas durante o uso do app',
                  subtitulo: 'Mais economia de bateria e privacidade.',
                  valor: _permitirGpsApenasUso,
                  onChanged: (v) => setState(() => _permitirGpsApenasUso = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. PAGAMENTOS
            _buildBloco(
              titulo: '5. Pagamentos',
              icone: Icons.credit_card_outlined,
              children: [
                _buildLink(
                  icone: Icons.payment_outlined,
                  titulo: 'Forma de pagamento atual',
                  sufixoTexto: 'Visa final 4582',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.swap_horiz_outlined,
                  titulo: 'Alterar método de pagamento',
                  subtitulo: 'Adicione ou altere seu cartão ou PIX.',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.receipt_long_outlined,
                  titulo: 'Histórico financeiro',
                  subtitulo: 'Veja seus pagamentos e recibos.',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 6. SUPORTE
            _buildBloco(
              titulo: '6. Suporte',
              icone: Icons.headset_mic_outlined,
              children: [
                _buildLink(
                  icone: Icons.help_outline,
                  titulo: 'Central de ajuda',
                  subtitulo: 'Tutoriais, guias e artigos úteis.',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.phone_outlined,
                  titulo: 'Falar com suporte',
                  subtitulo: 'Nossa equipe está pronta para te ajudar.',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.question_answer_outlined,
                  titulo: 'Perguntas frequentes',
                  subtitulo: 'Tire suas dúvidas rapidamente.',
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BOTÃO SALVAR
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
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  _salvando ? 'Salvando...' : 'Salvar Alterações',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloco({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: AppCores.azulPrincipal),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSeletorTresOpcoes({
    required List<String> opcoes,
    required String selecionado,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: opcoes.map((opcao) {
          final isSelected = opcao == selecionado;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(opcao),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppCores.azulPrincipal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    opcao,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitch({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppCores.azulPrincipal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 18, color: AppCores.azulPrincipal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                Text(subtitulo, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: valor,
            activeColor: AppCores.azulPrincipal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLink({
    required IconData icone,
    required String titulo,
    String? subtitulo,
    String? sufixoTexto,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Em breve!')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppCores.azulPrincipal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 18, color: AppCores.azulPrincipal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  if (subtitulo != null)
                    Text(subtitulo, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (sufixoTexto != null) ...[
              Text(sufixoTexto, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}