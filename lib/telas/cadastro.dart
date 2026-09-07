import 'package:flutter/material.dart';
import '../widgets/botoes.dart';
import '../widgets/campos.dart';
import '../widgets/secao_endereco.dart';
import '../widgets/indicador_senha.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  static const Color azulResponsavel = Color(0xFF1D58E2);
  static const Color laranjaMotorista = Color(0xFFFF5C00);

  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _senhaController = TextEditingController();

  String _senha = '';

  @override
  void dispose() {
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String perfil = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Responsável';
    final bool isResponsavel = perfil == 'Responsável';
    final Color corPerfil = isResponsavel ? azulResponsavel : laranjaMotorista;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topo / Voltar
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: 18, color: corPerfil),
                    label: Text('Voltar', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),

                // Badge Perfil
                Center(
                  child: Chip(
                    avatar: Icon(isResponsavel ? Icons.person : Icons.directions_bus, size: 16, color: corPerfil),
                    label: Text(perfil, style: TextStyle(color: corPerfil, fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: corPerfil.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 8),

                Center(child: Text('Cadastro de $perfil', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 4),
                Center(child: Text('Preencha seus dados para criar sua conta.', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                const SizedBox(height: 20),

                // Foto (Opcional)
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.camera_alt_outlined, color: Colors.grey[600], size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text('Adicionar foto (opcional)', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campos Pessoais
                const CampoTextoCustomizado(hintText: 'Nome completo', prefixIcon: Icons.person_outline),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'CPF', prefixIcon: Icons.badge_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'Telefone / WhatsApp', prefixIcon: Icons.phone_outlined),
                const SizedBox(height: 10),
                const CampoTextoCustomizado(hintText: 'E-mail', prefixIcon: Icons.email_outlined),
                const SizedBox(height: 16),

                // WIDGET REUTILIZÁVEL: Seção de Endereço
                SecaoEndereco(
                  cepController: _cepController,
                  ruaController: _ruaController,
                  numeroController: _numeroController,
                  bairroController: _bairroController,
                ),
                const SizedBox(height: 16),

                // Seção de Senha
                const Text('Segurança da Conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),

                CampoTextoCustomizado(
                  controller: _senhaController,
                  hintText: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
                
                // WIDGET REUTILIZÁVEL: Indicador Visual de Senha
                IndicadorSenha(senha: _senha),
                const SizedBox(height: 10),

                const CampoTextoCustomizado(
                  hintText: 'Confirmar senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Botão de Criar Conta
                BotaoPrincipal(
                  texto: 'Criar minha conta',
                  icone: Icons.person_add_alt_1,
                  cor: corPerfil,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                      child: Text('Fazer login', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}