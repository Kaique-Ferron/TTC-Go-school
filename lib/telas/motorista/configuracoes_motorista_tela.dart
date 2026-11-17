import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/preferencias_provider.dart';
import '../../theme/cores.dart';
import '../../widgets/badge_icone.dart';
import '../../widgets/shell_motorista.dart';
import '../suporte/tela_politica_privacidade.dart';
import '../suporte/tela_suporte.dart';

class ConfiguracoesMotoristaTela extends StatelessWidget {
  const ConfiguracoesMotoristaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellMotorista(
      itemSelecionado: 'Configurações',
      builder: (context) => const _ConteudoConfiguracoesMotorista(),
    );
  }
}

class _ConteudoConfiguracoesMotorista extends StatelessWidget {
  const _ConteudoConfiguracoesMotorista();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferenciasProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
          ),
          const SizedBox(height: 4),
          Text(
            'Personalize sua experiência no GoSchool.',
            style: TextStyle(color: AppCores.textoSecundario(context), fontSize: 14),
          ),
          const SizedBox(height: 20),

          _buildBloco(
            context,
            titulo: 'Aparência',
            icone: Icons.palette_outlined,
            children: [
              const Text('Tema', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSeletorTresOpcoes(
                context,
                opcoes: const ['Claro', 'Escuro', 'Automático'],
                selecionado: prefs.tema,
                onSelect: (tema) => prefs.salvar(tema: tema, tamanhoFonte: prefs.tamanhoFonte),
              ),
              const SizedBox(height: 16),
              const Text('Tamanho da fonte', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSeletorTresOpcoes(
                context,
                opcoes: const ['Pequena', 'Média', 'Grande'],
                selecionado: prefs.tamanhoFonte,
                onSelect: (tamanho) => prefs.salvar(tema: prefs.tema, tamanhoFonte: tamanho),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildBloco(
            context,
            titulo: 'Privacidade e Segurança',
            icone: Icons.shield_outlined,
            children: [
              _buildLink(
                context,
                icone: Icons.privacy_tip_outlined,
                titulo: 'Política de privacidade',
                subtitulo: 'LGPD e como protegemos seus dados.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaPoliticaPrivacidade()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildBloco(
            context,
            titulo: 'Suporte',
            icone: Icons.headset_mic_outlined,
            children: [
              _buildLink(
                context,
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
                context,
                icone: Icons.phone_outlined,
                titulo: 'Falar com suporte',
                subtitulo: 'Nossa equipe está pronta para te ajudar.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaSuporte(abrirDireto: SecaoSuporte.contato)),
                ),
              ),
              const Divider(height: 1),
              _buildLink(
                context,
                icone: Icons.question_answer_outlined,
                titulo: 'Perguntas frequentes',
                subtitulo: 'Tire suas dúvidas rapidamente.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaSuporte(abrirDireto: SecaoSuporte.faq)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBloco(
    BuildContext context, {
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppCores.superficie(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppCores.borda(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BadgeIcone(icone: icone, cor: AppCores.laranjaMotorista, tamanho: 26),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSeletorTresOpcoes(
    BuildContext context, {
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
                          colors: [AppCores.laranjaClaro, AppCores.laranjaMotorista],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppCores.laranjaMotorista.withValues(alpha: 0.4),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppCores.textoPrincipal(context),
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

  Widget _buildLink(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    String? subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppCores.laranjaMotorista.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 18, color: AppCores.laranjaMotorista),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppCores.textoPrincipal(context)),
                  ),
                  if (subtitulo != null)
                    Text(
                      subtitulo,
                      style: TextStyle(fontSize: 11.5, color: AppCores.textoSecundario(context)),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppCores.textoSecundario(context)),
          ],
        ),
      ),
    );
  }
}
