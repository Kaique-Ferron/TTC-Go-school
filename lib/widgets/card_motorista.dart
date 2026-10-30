import 'package:flutter/material.dart';
import '../models/motorista_model.dart';
import '../theme/cores.dart';
import 'avaliacao_media.dart';
import 'foto_perfil_provider.dart';

/// Card de um motorista real (vindo do Firestore) na tela de "Procurar
/// Motorista". Mostra só dados que realmente existem no cadastro — nada de
/// "escolas atendidas" ou "total de avaliações" mockados.
class CardMotorista extends StatelessWidget {
  final Motorista motorista;
  final bool temFilhoCadastrado;
  final VoidCallback onVerDetalhes;

  const CardMotorista({
    super.key,
    required this.motorista,
    required this.temFilhoCadastrado,
    required this.onVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    final vagas = motorista.criancasManha + motorista.criancasTarde;

    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Cabeçalho: Foto, Nome, Selo Verificado e Avaliação
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppCores.azulPrincipal.withValues(alpha: 0.1),
                backgroundImage: fotoPerfilProvider(motorista.fotoPerfil),
                child: motorista.fotoPerfil.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 32,
                        color: AppCores.azulPrincipal,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            motorista.nome,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppCores.textoPrincipal(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppCores.azulPrincipal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AvaliacaoMedia(
                      motoristaUid: motorista.uid,
                      iconSize: 13,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 13,
                          color: AppCores.textoSecundario(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${motorista.veiculo} • ${motorista.placa}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppCores.textoSecundario(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'Registro: ${motorista.crm}',
            style: TextStyle(
              fontSize: 11,
              color: AppCores.textoSecundario(context),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),
          Text(
            '$vagas vaga${vagas == 1 ? '' : 's'} ${vagas == 1 ? 'disponível' : 'disponíveis'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),

          // Botão Bloqueado ou Desbloqueado conforme posse de filho cadastrado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: temFilhoCadastrado ? onVerDetalhes : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: temFilhoCadastrado
                    ? AppCores.azulPrincipal
                    : AppCores.fundo(context),
                elevation: temFilhoCadastrado ? 4 : 0,
                shadowColor: AppCores.azulPrincipal.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: Icon(
                temFilhoCadastrado
                    ? Icons.visibility_outlined
                    : Icons.lock_outlined,
                size: 15,
                color: temFilhoCadastrado
                    ? Colors.white
                    : AppCores.textoSecundario(context),
              ),
              label: Text(
                'Ver detalhes',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: temFilhoCadastrado
                      ? Colors.white
                      : AppCores.textoSecundario(context),
                ),
              ),
            ),
          ),

          if (!temFilhoCadastrado) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Cadastre um filho para desbloquear esta função.',
                style: TextStyle(
                  fontSize: 10,
                  color: AppCores.textoSecundario(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
