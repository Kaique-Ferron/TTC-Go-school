class Cadastro {
  String nome;
  String email;
  int telefone;
  int cpf;
  int nascimento;
  String senha;





  Cadastro({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.nascimento,
    required this.senha,
  });

  // Converte um JSON em um objeto Cadastro

  factory Cadastro.fromJson(Map<String, dynamic> json){
    return Cadastro(

      nome: json["nome"] ?? "",
      email: json["email"] ?? "",
      telefone: json["telefone"] ?? "",
      cpf: json["cpf"] ?? "",
      nascimento: json["nascimento"] ?? "",
      senha: json["senha"] ?? "",
    );
  }

}