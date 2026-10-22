/// Uma criança na rota de um motorista — montada a partir das contratações
/// ativas (collectionGroup), usada pela tela de Chamada.
class CriancaRota {
  final String filhoId;
  final String nome;
  final String periodo;
  final String responsavelUid;
  final String responsavelNome;

  const CriancaRota({
    required this.filhoId,
    required this.nome,
    required this.periodo,
    required this.responsavelUid,
    required this.responsavelNome,
  });
}
