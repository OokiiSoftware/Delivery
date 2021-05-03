class Loja {

  //region Variáveis
  String _id;
  String _nome;
  String _descricao;
  String _email;
  String _telefone;
  String _endececo;
  String _foto;
  //endregion

  //region get set

  String get id => _id??= '';
  set id(String value) => _id = value;

  String get nome => _nome??= '';
  set nome(String value) => _nome = value;

  String get foto => _foto??= '';
  set foto(String value) => _foto = value;

  String get endececo => _endececo??= '';
  set endececo(String value) => _endececo = value;

  String get telefone => _telefone??= '';
  set telefone(String value) => _telefone = value;

  String get email => _email??= '';
  set email(String value) => _email = value;

  String get descricao => _descricao??= '';
  set descricao(String value) => _descricao = value;

  //endregion

}
