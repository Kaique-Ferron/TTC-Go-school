import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../painel_principal/painel_principal_tela.dart';
import 'landpage-tela.dart';

/// Tela "Início" do Responsável: enquanto ele ainda não contratou nenhum
/// motorista, mostra a landpage (busca/"Encontrar uma van"); depois da
/// primeira contratação, passa a mostrar o painel de acompanhamento do
/// transporte. É reativo (StreamBuilder), não uma escolha fixa no login —
/// se o status da contratação mudar depois, a tela de início muda junto.
class TelaInicioResponsavel extends StatelessWidget {
  const TelaInicioResponsavel({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.uidAtual;
    if (uid == null) return const LandpageTela();

    return StreamBuilder<bool>(
      stream: FirestoreService.instance.temContratacaoAtivaStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final jaContratouMotorista = snapshot.data ?? false;
        return jaContratouMotorista ? const PainelPrincipalTela() : const LandpageTela();
      },
    );
  }
}
