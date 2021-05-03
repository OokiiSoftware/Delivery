import 'dart:convert';
import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'firebase.dart';
import 'logs.dart';

class Produtos {
  static const TAG = 'Produtos';

  static Produtos instance = Produtos();

  static Function(Produto) onProdutoAdded;
  static Function(Produto) onProdutoRemoved;
  static Function(Combo) onComboAdded;
  static Function(Combo) onComboRemoved;

  Map<String, Produto> data = Map();
  Map<String, Combo> combos = Map();
  Map<String, ProdutoGroup> groups = Map();

  void add({Produto produto, Combo combo}) {
    if (produto != null) {
      data[produto.id] = produto;
      _addToGroup(produto);

      onProdutoAdded?.call(produto);
    }
    if (combo != null) {
      combos[combo.id] = combo;
      onComboAdded?.call(combo);
    }
  }

  void _addToGroup(Produto item) {
    String itemName = item.nome;
    if (!groups.containsKey(itemName)) {
      groups[itemName] = ProdutoGroup();
    }
    groups[itemName].items.add(item);
  }

  void remove({Produto produto, Combo combo}) {
    if (produto != null) {
      data.remove(produto.id);
      var group = groups[produto.nome];
      if (group != null) {
        group.items.removeWhere((x) => x.id == produto.id);
      }

      onProdutoRemoved?.call(produto);
    }
    if (combo != null) {
      combos.remove(combo.id);
      onComboRemoved?.call(combo);
    }
  }

  Produto get(String id) => data[id];

  Combo getCombo(String id) => combos[id];

  Map<String, ProdutoGroup> groupsSemNaoAVendas() {
    Map<String, ProdutoGroup> temp = Map();
    temp.addAll(groups);
    groups.values.forEach((element) {

    });

    return temp;
  }

  Future<bool> save() async {
    return await Preferences.setString(jsonEncode(toMap()), PreferencesKey.PRODUTOS);
  }

  List<String> categorias({bool removeNaoAVenda = true}) {
    List<String> d = [];
    data.forEach((key, value) {
      if (removeNaoAVenda && !value.isAVenda) {

      } else if (!d.contains(value.categoria.toLowerCase()))
        d.add(value.categoria.toLowerCase());
    });

    return d..sort((a, b) => a.compareTo(b));
   }
  List<String> tamanhos() {
    List<String> d = [];
    data.forEach((key, value) {
      if (!d.contains(value.tamanho.toLowerCase()))
        d.add(value.tamanho.toLowerCase());
    });

    return d..sort((a, b) => a.compareTo(b));
   }

  Future<bool> load() async {
    var dataTemp = jsonDecode(Preferences.getString(PreferencesKey.PRODUTOS));
    if (dataTemp  == null)
      return true;
    var temp = Produto.fromJsonList(dataTemp);
    if (temp != null)
      _setProdutosData(temp);
    Log.e(TAG, 'load', 'OK');
    return true;
  }

  Future<Map<String, Produto>> baixar({bool save = false}) async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.PRODUTOS)
          .once();

      var temp = Produto.fromJsonList(result.value);
      if (temp != null) {
        _setProdutosData(temp);
        if (save)
          this.save();
      }
    } catch(e) {
      Log.e(TAG, 'baixar', e);
    }
    return data;
  }
  Future<Map<String, Combo>> baixarCombos({bool save = false}) async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.COMBOS)
          .once();

      var temp = Combo.fromJsonList(result.value);
      if (temp != null) {
        combos = temp;
        if (save)
          this.save();

        combos.forEach((comboKey, value) {
          value.items.forEach((produtoKey, quant) {
            Produto temp = data[produtoKey];
            if (temp != null)
              value.itemsD[produtoKey] = Produto.fromJson(temp.toJson())..quantidade = quant;
          });
        });
      }
    } catch(e) {
      Log.e(TAG, 'baixarCombos', e);
    }
    return combos;
  }

  void _setProdutosData(Map<String, Produto> data) {
    if (data == null)
      return;

    data.forEach((key, value) {
      _addToGroup(value);

    });
    this.data = data;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    data.forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }
}