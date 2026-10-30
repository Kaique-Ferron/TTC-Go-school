import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/sessao_provider.dart';
import '../../../services/preferencias_provider.dart';
import '../../../theme/cores.dart';
import '../../../widgets/badge_icone.dart';
import '../../../widgets/navbar_responsavel.dart';
import '../../../widgets/nav_inferior_responsavel.dart';
import '../suporte/tela_suporte.dart';
import '../suporte/tela_politica_privacidade.dart';

class ConfiguracoesTela extends StatefulWidget {
  const ConfiguracoesTela({super.key});

  @override
  State<ConfiguracoesTela> createState() => _ConfiguracoesTelaState();
}

class _ConfiguracoesTelaState extends State<ConfiguracoesTela> {
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

  /// Aplica a aparência na hora (sem botão de "salvar" separado): manda
  /// direto pro PreferenciasProvider, que troca o tema do app inteiro,
  /// persiste no Firestore e notifica — essa tela observa o provider
  /// (context.watch), então o seletor reflete sozinho, sem cópia local que
  /// pudesse ficar dessincronizada do valor de verdade.
  void _mudarTema(String tema) {
    final prefs = context.read<PreferenciasProvider>();
    prefs.salvar(tema: tema, tamanhoFonte: prefs.tamanhoFonte);
  }

  void _mudarTamanhoFonte(String tamanho) {
    final prefs = context.read<PreferenciasProvider>();
    prefs.salvar(tema: prefs.tema, tamanhoFonte: tamanho);
  }

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;
    final prefs = context.watch<PreferenciasProvider>();
    if (!logado) {
      return Scaffold(
        backgroundColor: AppCores.fundo(context),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            child: const Text(
              'Sessão expirada. Toque para fazer login novamente.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const NavbarResponsavel(itemSelecionado: 'Configurações'),
      bottomNavigationBar: const NavInferiorResponsavel(
        abaSelecionada: 'Perfil',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalize sua experiência no GoSchool.',
              style: TextStyle(
                color: AppCores.textoSecundario(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // 1. APARÊNCIA
            _buildBloco(
              titulo: '1. Aparência',
              icone: Icons.palette_outlined,
              children: [
                const Text(
                  'Tema',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSeletorTresOpcoes(
                  opcoes: ['Claro', 'Escuro', 'Automático'],
                  selecionado: prefs.tema,
                  onSelect: _mudarTema,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tamanho da fonte',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSeletorTresOpcoes(
                  opcoes: ['Pequena', 'Média', 'Grande'],
                  selecionado: prefs.tamanhoFonte,
                  onSelect: _mudarTamanhoFonte,
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
                  subtitulo:
                      'Seja avisado quando seu filho embarcar ou desembarcar.',
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
                  onChanged: (v) =>
                      setState(() => _notifLembretesPagamento = v),
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
                _buildLink(icone: Icons.lock_outline, titulo: 'Alterar senha'),
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
                  subtitulo:
                      'Veja e remova dispositivos conectados à sua conta.',
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.privacy_tip_outlined,
                  titulo: 'Política de privacidade',
                  subtitulo: 'LGPD e como protegemos seus dados.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaPoliticaPrivacidade(),
                    ),
                  ),
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
                  subtitulo:
                      'Permite que o motorista veja a localização do seu filho.',
                  valor: _compartilharLocalizacaoRota,
                  onChanged: (v) =>
                      setState(() => _compartilharLocalizacaoRota = v),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaSuporte()),
                  ),
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.phone_outlined,
                  titulo: 'Falar com suporte',
                  subtitulo: 'Nossa equipe está pronta para te ajudar.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TelaSuporte(abrirDireto: SecaoSuporte.contato),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildLink(
                  icone: Icons.question_answer_outlined,
                  titulo: 'Perguntas frequentes',
                  subtitulo: 'Tire suas dúvidas rapidamente.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TelaSuporte(abrirDireto: SecaoSuporte.faq),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
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
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: escuro
              ? [AppCores.superficie(context), AppCores.superficie(context)]
              : const [Colors.white, Color(0xFFFCFDFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppCores.borda(context)),
        boxShadow: [
          BoxShadow(
            color: AppCores.azulPrincipal.withValues(alpha: escuro ? 0.2 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BadgeIcone(icone: icone, cor: AppCores.azulPrincipal, tamanho: 26),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppCores.textoPrincipal(context),
                ),
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
        color: AppCores.fundo(context),
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
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppCores.azulClaro, AppCores.azulPrincipal],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppCores.azulPrincipal.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opcao,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : AppCores.textoPrincipal(context),
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
          BadgeIcone(icone: icone, cor: AppCores.azulPrincipal, tamanho: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppCores.textoPrincipal(context),
                  ),
                ),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppCores.textoSecundario(context),
                  ),
                ),
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em breve!')));
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
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppCores.textoPrincipal(context),
                    ),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppCores.textoSecundario(context),
                      ),
                    ),
                ],
              ),
            ),
            if (sufixoTexto != null) ...[
              Text(
                sufixoTexto,
                style: TextStyle(
                  fontSize: 12,
                  color: AppCores.textoSecundario(context),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppCores.textoSecundario(context),
            ),
          ],
        ),
      ),
    );
  }
}
