import 'package:delivery/auxiliar/import.dart';
import 'import.dart';

class Combo {

  //region Variáveis
  static const String TAG = "Combo";

  String _id;
  String _nome;
  Map<String, int> _items;
  double _preco;
  int _quantidade;
  bool _isAVenda;

  Map<String, Produto> itemsD = Map();
  //endregion

  //region construtores

  Combo();

  Combo.fromJson(Map map) {
    if (map == null)
      return;
    id = map['id'];
    nome = map['nome'];
    isAVenda = map['isAVenda'];
    preco = double.tryParse(map['preco'].toString());

    if (map['items'] != null) {
      Map temp = map['items'];
      temp.forEach((key, value) {
        items[key] = value;
      });
    }
  }

  static Map<String, Combo> fromJsonList(Map map) {
    Map<String, Combo> data = Map();
    for (var key in map.keys)
      data[key] = Combo.fromJson(map[key]);
    return data;
  }

  Map toJson() => {
    'id': id,
    'nome': nome,
    'preco': preco,
    'items': items,
    'isAVenda': isAVenda,
  };

  //endregion

  //region metodos

  Future<bool> salvar() async {
    try {
      await FirebaseOki.database
          .child(FirebaseChild.COMBOS)
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
          .child(FirebaseChild.COMBOS)
          .child(id)
          .remove();

      Log.d(TAG, 'delete', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return false;
    }
  }

  List<Produto> toList() => itemsD.values.toList();

  Produto getProduto(int index) => toList()[index];

  //endregion

  //region get set

  String get id => _id??= null;
  set id(String value) => _id = value;

  bool get isAVenda => _isAVenda??= false;
  set isAVenda(bool value) => _isAVenda = value;

  int get quantidade => _quantidade??= 0;
  set quantidade(int value) => _quantidade = value;

  double get preco => _preco??= 0;
  set preco(double value) => _preco = value;

  Map<String, int> get items => _items??= Map();
  set items(Map<String, int> value) => _items = value;

  String get nome => _nome??= '';
  set nome(String value) => _nome = value;

  //endregion

}