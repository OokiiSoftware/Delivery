import 'package:delivery/auxiliar/import.dart';
import 'import.dart';

class Estabelecimento {
  static const TAG = 'Estabelecimento';

  String nome = '';
  String email = '';
  String telefone = '';
  Endereco endereco = Endereco();

  Estabelecimento();

  Estabelecimento.fromJson(Map map) {
    nome = map['nome'];
    email = map['email'];
    telefone = map['telefone'];

    if (map['endereco'] != null)
      endereco = Endereco.fromJson(map['endereco']);
  }

  Map toJson() => {
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'endereco': endereco.toJson(),
  };

  Future<bool> salvar() async {
    try {
      await FirebaseOki.database
          .child(FirebaseChild.ESTABELECIMENTO)
          .set(toJson());

      return true;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  static Future<Estabelecimento> baixar() async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.ESTABELECIMENTO)
          .once();

      return Estabelecimento.fromJson(result.value);

    } catch(e) {
      Log.e(TAG, 'baixar', e);
      return null;
    }
  }
}