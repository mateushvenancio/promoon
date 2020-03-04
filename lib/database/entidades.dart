class Loja {
  String nome;
  String endereco;
  int cnpj;
  double latitude = 0;
  double longitude = 0;

  Loja(this.nome, this.endereco, this.cnpj, this.latitude, this.longitude);
}

class Promocao {
  String nome;
  String loja;
  String categoria;
  String usuario;
  double latitude = 0;
  double longitude = 0;

  double precoOriginal;
  double precoAtual;

  String foto;

  bool ativo = true;

  Promocao(this.nome, this.foto, this.loja, this.latitude, this.longitude,
      this.precoOriginal, this.precoAtual, this.categoria, this.usuario);
}

class Usuario {
  String nome = "";
  String email = "";
  String senha = "";
  int celular = 0;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this.nome,
      "email": this.email,
      "celular": this.celular,
    };

    return map;
  }

  Usuario();
}
