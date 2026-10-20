import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sessao_provider.dart';
import '../telas/auth/selecao_perfil/selecao_perfil.dart';
import '../telas/auth/cadastro/cadastro.dart';
import '../telas/auth/recuperar_senha/recuperar_senha.dart';
import '../telas/landpage/landpage-tela.dart';
import '../telas/meu_perfil/tela_perfil.dart';
import '../telas/meus_filhos/meus_filhos.dart';
import '../telas/configuracoes/configuracoes_tela.dart'; // <--- Import corrigido com ../
import 'auth_gate.dart';
import '../telas/procurar_motorista/procurar_motorista_tela.dart';
import '../telas/chat/tela_conversas.dart';



import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class GoSchoolApp extends StatelessWidget {
  const GoSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessaoProvider(),
      child: MaterialApp(
        title: 'GoSchool',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        // Na Web, o app inteiro fica com a cara de um celular (mesma largura
        // do cartão de login) centralizado na janela do navegador, em vez de
        // esticar o layout mobile pela tela toda do computador.
        builder: kIsWeb
            ? (context, child) {
                return ColoredBox(
                  color: const Color(0xFFE2E6ED),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: child,
                    ),
                  ),
                );
              }
            : null,
        home: const AuthGate(),
        routes: {
          '/selecao-perfil': (context) => const TelaSelecaoPerfil(),
          '/cadastro': (context) => const TelaCadastro(),
          '/recuperar-senha': (context) => const TelaRecuperarSenha(),
          '/landpage': (context) => const LandpageTela(),
          '/meu-perfil': (context) => const TelaPerfil(),
          '/meus-filhos': (context) => const MeusFilhosTela(),
          '/configuracoes': (context) => const ConfiguracoesTela(),
          '/procurar-motorista': (context) => const ProcurarMotoristaTela(),
          '/chat': (context) => const TelaConversas(),
        },
      ),
    );
  }
}