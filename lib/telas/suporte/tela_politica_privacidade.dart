import 'package:flutter/material.dart';
import '../../theme/cores.dart';

/// Política de Privacidade — conteúdo real (não um placeholder "em breve"),
/// fundamentado na LGPD e nas demais leis brasileiras relevantes pra um app
/// que lida com dados de crianças (filhos dos Responsáveis) e localização.
class TelaPoliticaPrivacidade extends StatelessWidget {
  const TelaPoliticaPrivacidade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.fundo(context),
      appBar: AppBar(
        title: const Text('Privacidade e Segurança'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppCores.azulPrincipal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppCores.azulPrincipal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gpp_good_outlined, color: AppCores.azulPrincipal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O GoSchool trata os dados de responsáveis, motoristas e crianças em '
                      'conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018) '
                      'e com o Estatuto da Criança e do Adolescente (ECA — Lei nº 8.069/1990).',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue.shade100
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _secao(
              context,
              icone: Icons.description_outlined,
              titulo: '1. Quais dados coletamos',
              corAcento: AppCores.azulPrincipal,
              paragrafos: const [
                'Dados de cadastro: nome, e-mail, telefone, CPF e endereço, tanto de Responsáveis '
                    'quanto de Motoristas (e CNH/placa/veículo no caso do Motorista).',
                'Dados dos filhos cadastrados pelo Responsável: nome, idade/ano escolar, escola, '
                    'turno, tipo sanguíneo e alergias — usados só para o transporte escolar.',
                'Dados de uso: mensagens trocadas no chat, contratações feitas, avaliações enviadas '
                    'e, quando autorizado, localização durante a rota.',
              ],
            ),

            _secao(
              context,
              icone: Icons.gavel_outlined,
              titulo: '2. Base legal (LGPD)',
              corAcento: AppCores.azulClaro,
              paragrafos: const [
                'Tratamos esses dados com base no consentimento do titular (art. 7º, I), na '
                    'execução do contrato de transporte entre Responsável e Motorista (art. 7º, V) '
                    'e no legítimo interesse de garantir a segurança do serviço (art. 7º, IX).',
              ],
            ),

            _secao(
              context,
              icone: Icons.child_care_outlined,
              titulo: '3. Dados de crianças e adolescentes',
              corAcento: AppCores.rosa,
              paragrafos: const [
                'Por envolver dados de crianças, seguimos o art. 14 da LGPD: essas informações só '
                    'são tratadas no melhor interesse do titular e com o consentimento de ao menos '
                    'um dos pais ou responsável legal — que é quem faz o cadastro.',
                'Em conjunto com o ECA (Lei nº 8.069/1990), tratamos informações de saúde da '
                    'criança (tipo sanguíneo, alergias) com o cuidado adicional previsto para dados '
                    'sensíveis (art. 11 da LGPD), usadas apenas em situações de emergência durante o transporte.',
              ],
            ),

            _secao(
              context,
              icone: Icons.share_outlined,
              titulo: '4. Com quem compartilhamos',
              corAcento: AppCores.laranjaMotorista,
              paragrafos: const [
                'O Motorista só vê os dados do filho e do Responsável depois que a contratação é '
                    'confirmada — nunca antes. Não vendemos nem compartilhamos dados com terceiros '
                    'para fins de publicidade.',
                'A infraestrutura de armazenamento (Firebase/Google Cloud) segue os padrões de '
                    'segurança exigidos pela LGPD e pelo Marco Civil da Internet (Lei nº 12.965/2014) '
                    'para guarda de registros e dados pessoais.',
              ],
            ),

            _secao(
              context,
              icone: Icons.verified_user_outlined,
              titulo: '5. Seus direitos como titular',
              corAcento: AppCores.verde,
              paragrafos: const [
                'Conforme o art. 18 da LGPD, você pode a qualquer momento: confirmar o tratamento, '
                    'acessar, corrigir, solicitar a exclusão ou a portabilidade dos seus dados, e '
                    'revogar o consentimento dado no cadastro.',
                'Para exercer esses direitos, use o item "Editar perfil" para corrigir seus dados, '
                    'ou fale com nosso suporte (Configurações → Suporte → Falar com suporte) para '
                    'solicitar exclusão ou exportação completa.',
              ],
            ),

            _secao(
              context,
              icone: Icons.lock_outline,
              titulo: '6. Segurança e retenção',
              corAcento: AppCores.roxo,
              paragrafos: const [
                'Senhas nunca são armazenadas em texto puro (gerenciadas pelo Firebase Authentication) '
                    'e a comunicação com nossos servidores é sempre criptografada (HTTPS/TLS).',
                'Mantemos os dados apenas enquanto a conta estiver ativa ou enquanto houver obrigação '
                    'legal de retenção; ao excluir a conta, os dados são removidos, exceto o que a lei '
                    'exigir manter por período determinado.',
              ],
            ),

            _secao(
              context,
              icone: Icons.update_outlined,
              titulo: '7. Alterações nesta política',
              corAcento: AppCores.ambar,
              paragrafos: const [
                'Podemos atualizar esta política para refletir mudanças no app ou na legislação. '
                    'Alterações relevantes serão avisadas dentro do próprio app.',
              ],
            ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppCores.superficie(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppCores.borda(context)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_outlined, color: AppCores.azulPrincipal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dúvidas sobre o tratamento dos seus dados? Fale com nosso Encarregado de '
                      'Dados (DPO) em dpo@goschool.com.br.',
                      style: TextStyle(fontSize: 12, color: AppCores.textoSecundario(context), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required Color corAcento,
    required List<String> paragrafos,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: corAcento.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icone, size: 16, color: corAcento),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(titulo, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppCores.textoPrincipal(context))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...paragrafos.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 34),
              child: Text(p, style: TextStyle(fontSize: 12.5, color: AppCores.textoSecundario(context), height: 1.45)),
            ),
          ),
        ],
      ),
    );
  }
}
