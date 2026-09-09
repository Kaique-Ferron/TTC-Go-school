class Endereco {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final bool erro;

  Endereco({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    this.erro = false,
  });

  // Converte o JSON retornado pela API ViaCEP para o objeto Dart
  factory Endereco.fromJson(Map<String, dynamic> json) {
    if (json['erro'] == true || json['erro'] == 'true') {
      return Endereco(
        cep: '',
        logradouro: '',
        complemento: '',
        bairro: '',
        localidade: '',
        uf: '',
        erro: true,
      );
    }

    return Endereco(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      erro: false,
    );
  }
}