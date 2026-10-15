import 'package:flutter/material.dart';
import '../theme/cores.dart';

class CardPassosCadastro extends StatelessWidget {
  final bool temFilhos;
  final VoidCallback onVerFilhos;

  const CardPassosCadastro({
    super.key,
    required this.temFilhos,
    required this.onVerFilhos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete seu cadastro',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildItemPasso(
            numero: '1',
            titulo: 'Conta criada',
            subtitulo: 'Parabéns! Sua conta foi criada com sucesso.',
            concluido: true,
          ),
          _buildItemPasso(
            numero: '2',
            titulo: 'Cadastre um filho',
            subtitulo: 'Adicione pelo menos um filho para continuar.',
            concluido: temFilhos,
            ativo: !temFilhos,
          ),
          _buildItemPasso(
            numero: '3',
            titulo: 'Solicite uma vaga',
            subtitulo: 'Escolha um motorista e solicite uma vaga.',
            concluido: false,
          ),
          _buildItemPasso(
            numero: '4',
            titulo: 'Acompanhe a rota',
            subtitulo: 'Acompanhe em tempo real o trajeto do seu filho.',
            concluido: false,
            ultimo: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerFilhos,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: AppCores.azulPrincipal),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              label: const Text(
                'Ver meus filhos',
                style: TextStyle(color: AppCores.azulPrincipal, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              icon: const Icon(Icons.chevron_right, size: 16, color: AppCores.azulPrincipal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPasso({
    required String numero,
    required String titulo,
    required String subtitulo,
    bool concluido = false,
    bool ativo = false,
    bool ultimo = false,
  }) {
    final Color corBase = concluido
        ? Colors.green
        : (ativo ? Colors.amber.shade800 : Colors.grey.shade400);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: concluido ? Colors.green : (ativo ? Colors.amber.shade700 : Colors.grey.shade300),
              child: concluido
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(numero, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            if (!ultimo)
              Container(
                width: 2,
                height: 36,
                color: Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corBase)),
              Text(subtitulo, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}