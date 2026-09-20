import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sessao_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

import '../telas/auth/login/login.dart';
import '../telas/meu_perfil/meu_perfil.dart';
import '../telas/motorista/tela_motorista.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<SessaoProvider>().logado;

    if (!logado) {
      return const TelaLogin();
    }

    final uid = AuthService.instance.uidAtual;

    if (uid == null) {
      return const TelaLogin();
    }

    return StreamBuilder(
      stream: FirestoreService.instance.usuarioStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Dados do usuário não encontrados.',
              ),
            ),
          );
        }

        final usuario = snapshot.data!;

        print('==============================');
        print('NOME: ${usuario.nome}');
        print('PERFIL: ${usuario.perfil}');
        print('TIPO PERFIL: ${usuario.tipoPerfil}');
        print('UID: $uid');
        print('==============================');

        if (usuario.tipoPerfil == 'motorista') {
          print('>>> ABRINDO TELA DO MOTORISTA');
          return const TelaMotorista();
        }

        print('>>> ABRINDO TELA DO RESPONSÁVEL');
        return const TelaMeuPerfil();
      },
    );
  }
}