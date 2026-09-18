import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/cores.dart';
import '../../widgets/botoes.dart';
import '../../widgets/campos.dart';

/// Tela de formulário para editar os dados do perfil do Responsável.
/// Recebe os dados atuais (já lidos pela TelaPerfil) para pré-preencher os campos.
class EditarPerfilTela extends StatefulWidget {
  final Map<String, dynamic>? dadosAtuais;

  const EditarPerfilTela({super.key, this.dadosAtuais});

  @override
  State<EditarPerfilTela> createState() => _EditarPerfilTelaState();
}

class _EditarPerfilTelaState extends State<EditarPerfilTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _enderecoController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.dadosAtuais?['nome'] as String? ?? '');
    _telefoneController = TextEditingController(text: widget.dadosAtuais?['telefone'] as String? ?? '');
    _enderecoController = TextEditingController(text: widget.dadosAtuais?['endereco'] as String? ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _salvando = true);
    try {
      // merge: true preserva campos que esta tela não edita (e-mail, tipoPerfil, criadoEm...).
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': _nomeController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informações atualizadas com sucesso!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dados pessoais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),

              CampoTextoCustomizado(
                controller: _nomeController,
                hintText: 'Nome completo',
                prefixIcon: Icons.person_outline,
                validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 12),
              CampoTextoCustomizado(
                controller: _telefoneController,
                hintText: 'Telefone / WhatsApp',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CampoTextoCustomizado(
                controller: _enderecoController,
                hintText: 'Endereço completo (rua, número, bairro)',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              BotaoPrincipal(
                texto: 'Salvar Informações',
                icone: Icons.check,
                cor: AppCores.azulPrincipal,
                carregando: _salvando,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
