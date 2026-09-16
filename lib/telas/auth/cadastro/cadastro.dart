import 'package:flutter/material.dart';
// Auth/Firestore temporariamente desativados para testes de navegação:
// import '../../../models/usuario.dart';
// import '../../../services/auth_service.dart';
// import '../../../services/firestore_service.dart';
import '../../../theme/cores.dart';
import '../../../widgets/botoes.dart';
import '../../../widgets/campos.dart';
import '../../../widgets/secao_endereco.dart';
import '../../../widgets/secao_motorista.dart';
import '../../../widgets/indicador_senha.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  // Controllers de Dados Pessoais
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Controllers de Endereço
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();

  // Controllers de Motorista
  final _cnhController = TextEditingController();
  final _licencaController = TextEditingController();
  final _placaController = TextEditingController();

  // Controllers de Senha
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  String _senha = '';

  // bool _carregando = false; // usado apenas pela chamada real de cadastro (desativada)

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cnhController.dispose();
    _licencaController.dispose();
    _placaController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // ===== Cadastro real com Firebase Auth + Firestore (temporariamente desativado para testes) =====
  // Future<void> _criarConta(String perfil) async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   if (_senhaController.text != _confirmarSenhaController.text) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: Colors.red),
  //     );
  //     return;
  //   }
  //
  //   setState(() => _carregando = true);
  //   try {
  //     final uid = await AuthService.instance.cadastrar(
  //       email: _emailController.text.trim(),
  //       senha: _senhaController.text,
  //     );
  //
  //     final usuario = Usuario(
  //       nome: _nomeController.text.trim(),
  //       email: _emailController.text.trim(),
  //       telefone: _telefoneController.text.trim(),
  //       cpf: _cpfController.text.trim(),
  //       perfil: perfil,
  //       cep: _cepController.text.trim(),
  //       rua: _ruaController.text.trim(),
  //       numero: _numeroController.text.trim(),
  //       bairro: _bairroController.text.trim(),
  //       cnh: _cnhController.text.trim(),
  //       licenca: _licencaController.text.trim(),
  //       placa: _placaController.text.trim(),
  //     );
  //
  //     await FirestoreService.instance.salvarUsuario(uid, usuario);
  //
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: Colors.green),
  //     );
  //     // Volta até a raiz: o AuthGate já mostra a tela logada, pois o
  //     // Firebase autentica o usuário automaticamente após o cadastro.
  //     Navigator.of(context).popUntil((route) => route.isFirst);
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(AuthService.descreverErro(e)), backgroundColor: Colors.red),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _carregando = false);
  //   }
  // }

  // Cadastro "fake" apenas para navegação durante os testes de tela
  // (não cria conta nem grava nada no Firebase).
  void _criarConta(String perfil) {
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/landpage');
  }

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    final String perfil = (ModalRoute.of(context)?.settings.arguments as String?) ?? 'Responsável';
    final bool isResponsavel = perfil == 'Responsável';
    final Color corPerfil = AppCores.porPerfil(perfil);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voltar
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

                  // Upload Foto
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

                  // Dados Pessoais
                  CampoTextoCustomizado(
                    controller: _nomeController,
                    hintText: 'Nome completo',
                    prefixIcon: Icons.person_outline,
                    validator: _obrigatorio,
                  ),
                  const SizedBox(height: 10),
                  CampoTextoCustomizado(
                    controller: _cpfController,
                    hintText: 'CPF',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    // Validação de CPF desativada por enquanto — aceita qualquer valor
                    // (inclusive aleatório) até a verificação real ser implementada.
                    // validator: (valor) {
                    //   final digitos = (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    //   if (digitos.length != 11) return 'CPF inválido';
                    //   return null;
                    // },
                  ),
                  const SizedBox(height: 10),
                  CampoTextoCustomizado(
                    controller: _telefoneController,
                    hintText: 'Telefone / WhatsApp',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (valor) {
                      final digitos = (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                      if (digitos.length < 10) return 'Telefone inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CampoTextoCustomizado(
                    controller: _emailController,
                    hintText: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) return 'Informe um e-mail';
                      if (!valor.contains('@') || !valor.contains('.')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seção exclusiva para Motorista
                  if (!isResponsavel) ...[
                    SecaoMotorista(
                      cnhController: _cnhController,
                      licencaController: _licencaController,
                      placaController: _placaController,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Seção de Endereço com Busca Automática por CEP
                  SecaoEndereco(
                    cepController: _cepController,
                    ruaController: _ruaController,
                    numeroController: _numeroController,
                    bairroController: _bairroController,
                  ),
                  const SizedBox(height: 16),

                  // Segurança
                  const Text('Segurança da Conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),

                  // Campo Senha
                  CampoTextoCustomizado(
                    controller: _senhaController,
                    hintText: 'Senha',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    onChanged: (val) => setState(() => _senha = val),
                    validator: (valor) {
                      if (valor == null || valor.length < 6) return 'Mínimo de 6 caracteres';
                      return null;
                    },
                  ),

                  IndicadorSenha(senha: _senha),
                  const SizedBox(height: 10),

                  CampoTextoCustomizado(
                    controller: _confirmarSenhaController,
                    hintText: 'Confirmar senha',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (valor) =>
                        (valor == null || valor.isEmpty) ? 'Confirme sua senha' : null,
                  ),
                  const SizedBox(height: 24),

                  // Botão de Criar Conta
                  BotaoPrincipal(
                    texto: 'Criar minha conta',
                    icone: Icons.person_add_alt_1,
                    cor: corPerfil,
                    onPressed: () => _criarConta(perfil),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Já tem uma conta? ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        child: Text('Fazer login', style: TextStyle(color: corPerfil, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
