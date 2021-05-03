import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'firebase.dart';
import 'logs.dart';

class Pedidos {
  static const TAG = 'Pedidos';

  static Pedidos instance = Pedidos();

  Pedido _pedidoTemp;
  Map<String, Pedido> data = Map();

  void add({Produto produto, Combo combo, Pedido pedido}) {
    if (_pedidoTemp == null)
      _pedidoTemp = Pedido('');

    if (produto != null) {
      _pedidoTemp.produtos[produto.id] = produto.quantidade;
    }
    if (combo != null) {
      _pedidoTemp.combos[combo.id] = combo.quantidade;
    }

    if (pedido != null)
      data[pedido.id] = pedido;

  }

  void remove({Produto produto, Pedido pedido, Combo combo}) {
    if (_pedidoTemp != null) {
      if (produto != null)
        _pedidoTemp.produtos.remove(produto.id);

      if (combo != null)
        _pedidoTemp.combos.remove(combo.id);
    }

    if (pedido != null)
      data.remove(pedido.id);
  }

  Pedido get getPedidoTemp => _pedidoTemp;

  double get tempPrecoTotal {
    if (_pedidoTemp == null)
      return 0;

    return _pedidoTemp.total;
  }

  Produto getProduto(String id) {
    if (data.isEmpty)
      return null;
    if (_pedidoTemp == null)
      return null;
    return Produtos.instance.get(id)..quantidade = (_pedidoTemp.produtos[id] ?? 0);
  }

  void resetTemp() => _pedidoTemp = null;

  Future<bool> save() async {
    return await Preferences.setObj(PreferencesKey.PEDIDOS, toMap());
  }

  Future<bool> load() async {
    var dataTemp = Preferences.getObj(PreferencesKey.PEDIDOS);
    if (dataTemp  == null)
      return true;
    var temp = Pedido.fromJsonList(dataTemp);
    if (temp != null)
      data = temp;
    Log.d(TAG, 'load', 'OK');
    return true;
  }

  Future<Map<String, Pedido>> baixar({bool save = false}) async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.PEDIDOS_PENDENTES)
          .once();

      if (result.value == null)
        return data;

      var temp = Pedido.fromJsonList(result.value);

      if (temp != null) {
        data.clear();
        data.addAll(temp);
      }

      if (save)
        this.save();
    } catch(e) {
      Log.e(TAG, 'baixar', e);
    }
    return data;
  }

  List<Pedido> toList() {
    return data.values.toList()..sort((a, b) => a.data.compareTo(b.data));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    data.forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }
}