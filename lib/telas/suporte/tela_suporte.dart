import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/cores.dart';
import 'tela_politica_privacidade.dart';

/// Seção pra abrir direto quando a tela é aberta a partir de um link
/// específico da tela de Configurações (em vez de sempre cair no topo).
enum SecaoSuporte { nenhuma, faq, contato }

/// Central de Suporte — reúne contato real (e-mail/telefone copiáveis) e
/// perguntas frequentes de verdade sobre o que o app já faz hoje, em vez do
/// SnackBar "Em breve!" que existia antes nos três links de Suporte.
class TelaSuporte extends StatefulWidget {
  final SecaoSuporte abrirDireto;

  const TelaSuporte({super.key, this.abrirDireto = SecaoSuporte.nenhuma});

  @override
  State<TelaSuporte> createState() => _TelaSuporteState();
}

class _TelaSuporteState extends State<TelaSuporte> {
  final _chaveFaq = GlobalKey();
  final _chaveContato = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.abrirDireto == SecaoSuporte.nenhuma) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chave = widget.abrirDireto == SecaoSuporte.faq ? _chaveFaq : _chaveContato;
      final ctx = chave.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _copiar(String valor, String rotulo) async {
    await Clipboard.setData(ClipboardData(text: valor));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$rotulo copiado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Central de Suporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precisa de ajuda com o GoSchool?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Fale com a gente ou veja as respostas pras dúvidas mais comuns.',
              style: TextStyle(fontSize: 13, color: AppCores.textoSecundario(context)),
            ),
            const SizedBox(height: 20),

            // ===== Contato =====
            Container(
              key: _chaveContato,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppCores.azulPrincipal, AppCores.azulEscuro],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Falar com o suporte',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildContato(
                    icone: Icons.email_outlined,
                    valor: 'suporte@goschool.com.br',
                    onCopiar: () => _copiar('suporte@goschool.com.br', 'E-mail'),
                  ),
                  const SizedBox(height: 10),
                  _buildContato(
                    icone: Icons.phone_outlined,
                    valor: '(11) 4000-5000',
                    onCopiar: () => _copiar('(11) 4000-5000', 'Telefone'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 10),
                      const Text(
                        'Seg. a sex., 8h às 18h',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===== FAQ =====
            Row(
              key: _chaveFaq,
              children: [
                const Icon(Icons.question_answer_outlined, color: AppCores.azulPrincipal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Perguntas frequentes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildFaq(
              'Como eu contrato um motorista?',
              'Toque em "Encontrar uma van" na tela de Início (ou na aba Serviços), '
                  'escolha um motorista com vaga disponível, veja os detalhes e confirme a contratação. '
                  'É preciso ter pelo menos um filho cadastrado antes.',
              corAcento: AppCores.azulPrincipal,
            ),
            _buildFaq(
              'Como falo com o motorista pelo app?',
              'Depois de contratar, vá em Mensagens — o motorista aparece automaticamente na sua lista '
                  'de contatos pra iniciar uma conversa.',
              corAcento: AppCores.azulClaro,
            ),
            _buildFaq(
              'Como avalio o motorista?',
              'Dentro da conversa com ele, toque no ícone de estrela no topo da tela. '
                  'Sua nota e comentário ficam visíveis pra outros responsáveis no card do motorista.',
              corAcento: AppCores.ambar,
            ),
            _buildFaq(
              'Esqueci minha senha, e agora?',
              'Na tela de login, toque em "Esqueci minha senha" e siga as instruções enviadas '
                  'por e-mail pra criar uma nova.',
              corAcento: AppCores.laranjaMotorista,
            ),
            _buildFaq(
              'Como edito os dados do meu filho?',
              'Em "Meus Filhos", toque no card do filho e depois em "Editar" pra atualizar escola, '
                  'turno, tipo sanguíneo ou alergias a qualquer momento.',
              corAcento: AppCores.roxo,
            ),
            _buildFaq(
              'Meus dados estão seguros?',
              'Sim. Tratamos os dados de acordo com a LGPD (Lei nº 13.709/2018) e com atenção especial '
                  'aos dados de crianças e adolescentes. Veja todos os detalhes na nossa Política de Privacidade.',
              corAcento: AppCores.verde,
              linkTexto: 'Ler Política de Privacidade',
              onLink: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaPoliticaPrivacidade()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContato({required IconData icone, required String valor, required VoidCallback onCopiar}) {
    return Row(
      children: [
        Icon(icone, color: Colors.white70, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(valor, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
        ),
        IconButton(
          onPressed: onCopiar,
          icon: const Icon(Icons.copy_outlined, color: Colors.white70, size: 16),
          tooltip: 'Copiar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildFaq(
    String pergunta,
    String resposta, {
    required Color corAcento,
    String? linkTexto,
    VoidCallback? onLink,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: corAcento.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: corAcento.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.help_outline, size: 16, color: corAcento),
          ),
          title: Text(
            pergunta,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppCores.textoPrincipal(context)),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resposta, style: TextStyle(fontSize: 12.5, color: AppCores.textoSecundario(context), height: 1.4)),
            if (linkTexto != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: onLink,
                child: Text(
                  linkTexto,
                  style: TextStyle(fontSize: 12.5, color: corAcento, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
