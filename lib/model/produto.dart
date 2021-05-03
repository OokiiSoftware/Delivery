import 'package:delivery/auxiliar/import.dart';

class Produto {

  //region Variáveis
  static const String TAG = "Produto";

  String id;
  String _nome;
  String _categoria;
  // String _foto;
  String _descricao;
  String _tamanho;
  double _preco;
  int _quantidade;
  bool _isAVenda;
  //endregion

  //region construtores

  Produto();

  Produto.fromJson(Map map) {
    id = map['id'];
    nome = map['nome'];
    // foto = map['foto'];
    isAVenda = map['isAVenda'];
    categoria = map['categoria'];
    descricao = map['descricao'];
    quantidade = map['quantidade'];
    tamanho = map['tamanho'];
    preco = double.parse(map['preco'].toString());
  }

  Map toJson() => {
    'id': id,
    'nome': nome,
    // 'foto': foto,
    'categoria': categoria,
    'descricao': descricao,
    'isAVenda': isAVenda,
    'tamanho': tamanho,
    'preco': preco,
  };

  static Map<String, Produto> fromJsonList(Map map) {
    Map<String, Produto> data = Map();
    for (var key in map.keys)
      data[key] = Produto.fromJson(map[key]);
    return data;
  }

  //endregion

  //region metodos

  bool valueNotNull(dynamic value) => value != null;

  Future<bool> salvar({bool saveFoto = true}) async {
    try {
      // if (saveFoto && isLocalFoto)
      //   if (!await uploadFoto())
      //     throw ('uploadFoto error');

      await FirebaseOki.database
          .child(FirebaseChild.PRODUTOS)
          .child(id)
          .set(toJson());

      Log.d(TAG, 'salvar', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  Future<bool> delete() async {
    try {
      await FirebaseOki.database
          .child(FirebaseChild.PRODUTOS)
          .child(id)
          .remove();

      Log.d(TAG, 'delete', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return false;
    }
  }

  /*Future<bool> uploadFoto() async {
    File file = new File(foto);
    if (file == null || !await file.exists()) {
      Log.d(TAG, 'uploadFoto', 'file Null');
      return false;
    }

    Log.d(TAG, 'uploadFoto', 'Iniciando');

    try {
      var ref = FirebaseOki.storage
          .child(FirebaseChild.PRODUTOS)
          .child(id + '.jpg');

      var taskSnapshot = await ref.putFile(file);
      var fileUrl = await taskSnapshot.ref.getDownloadURL();

      foto = fileUrl;
      Log.d(TAG, 'uploadFoto', 'OK', fileUrl);
      return true;
    } catch(e) {
      Log.e(TAG, 'uploadFoto Fail', e);
      return false;
    }
  }*/

  // bool get isLocalFoto => foto.contains('com.ookiisoftware.delivery');

  //endregion

  //region get set

  String get nome => _nome??= '';
  set nome(String value) => _nome = value;

  String get categoria => _categoria??= '';
  set categoria(String value) => _categoria = value;

  double get preco => _preco??= -1;
  set preco(double value) => _preco = value;

  bool get isAVenda => _isAVenda??= false;
  set isAVenda(bool value) => _isAVenda = value;

  String get descricao => _descricao??= '';
  set descricao(String value) => _descricao = value;

  int get quantidade => _quantidade??= 0;
  set quantidade(int value) => _quantidade = value;

  String get tamanho => _tamanho??= '';
  set tamanho(String value) => _tamanho = value;

  // String get foto => _foto??= '';
  // set foto(String value) => _foto = value;

  //endregion

}

class ProdutoGroup {
  List<Produto> items = [];

  double get precoMim {
    List<Produto> temp = [];
    temp.addAll(items);
    temp.sort(_sortBtPreco);
    if (temp.isNotEmpty)
      return temp[0].preco;
    else return 0;
  }
  double get precoMax {
    List<Produto> temp = [];
    temp.addAll(items);
    temp.sort(_sortBtPreco);
    if (temp.isNotEmpty)
      return temp[temp.length-1].preco;
    else return 0;
  }

  String get categoria {
    if (items.isEmpty)
      return '';
    return items[0].categoria;
  }
  String get nome {
    if (items.isEmpty)
      return '';
    return items[0].nome;
  }

  int _sortBtPreco(Produto a, Produto b) {
    return a.preco.compareTo(b.preco);
  }
}