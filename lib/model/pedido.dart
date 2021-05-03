import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';

class Pedido {

  //region Variáveis
  static const TAG = 'Pedido';

  String id;
  String _data;
  String _idCliente;
  int _formaPagamento;
  int _status;

  UserOki user;

  Map<String, int> _produtos;
  Map<String, int> _combos;
  //endregion

  Pedido(this.id);

  Pedido.fromJson(Map map) {
    id = map['id'];
    data = map['data'];
    status = map['status'];
    idCliente = map['idCliente'];
    formaPagamento = map['formaPagamento'];

    if (valueNotNull(map['produtos'])) {
      Map temp = map['produtos'];
      temp.forEach((key, value) {
        produtos[key] = value;
      });
    }
    if (valueNotNull(map['combos'])) {
      Map temp = map['combos'];
      temp.forEach((key, value) {
        combos[key] = value;
      });
    }
  }

  Map toJson() => {
    'id': id,
    'data': data,
    'status': status,
    'combos': combos,
    'produtos': produtos,
    'idCliente': idCliente,
    'formaPagamento': formaPagamento,
  };

  static Map<String, Pedido> fromJsonList(Map map) {
    Map<String, Pedido> data = Map();
    for (var key in map.keys)
      data[key] = Pedido.fromJson(map[key]);
    return data;
  }

  bool valueNotNull(dynamic value) => value != null;

  Future<bool> salvar() async {
    try {
      String child = FirebaseChild.PEDIDOS_PENDENTES;
      if (status == 4)
        child = FirebaseChild.PEDIDOS_CONCLUIDOS;

      delete();

      await FirebaseOki.database
          .child(child)
          .child(id)
          .set(toJson());
      return true;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  Future<bool> delete({bool ignoreStatus = false}) async {
    try {
      String child = FirebaseChild.PEDIDOS_CONCLUIDOS;
      if (status == 4 || ignoreStatus)
        child = FirebaseChild.PEDIDOS_PENDENTES;

      await FirebaseOki.database
          .child(child)
          .child(id)
          .remove();
      return true;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return false;
    }
  }
  Future<int> checkStatus() async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.PEDIDOS_PENDENTES)
          .child(data)
          .child('status')
          .once();

        return result.value;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return -1;
    }
  }

  double get total {
    double d = 0;

    produtos.forEach((key, quant) {
      d += quant * (Produtos.instance.get(key)?.preco ?? 0);
    });
    combos.forEach((key, quant) {
      d += quant * (Produtos.instance.getCombo(key)?.preco ?? 0);
    });
    return d;
  }

  String get statusS {
    switch(status) {
      case 0:
        return 'Não Finalizado';
      case 1:
        return 'Pendente';
      case 2:
        return 'Em Curso';
      case 3:
        return 'A Entregar';
      case 4:
        return 'Entregue';
      default:
        return '';
    }
  }

  //region get set

  Map<String, int> get produtos => _produtos??= Map();
  set produtos(Map<String, int> value) => _produtos = value;

  Map<String, int> get combos => _combos??= Map();
  set combos(Map<String, int> value) => _combos = value;

  int get status => _status??= 0;
  set status(int value) => _status = value;

  int get formaPagamento => _formaPagamento??= 0;
  set formaPagamento(int value) => _formaPagamento = value;

  String get idCliente => _idCliente??= '';
  set idCliente(String value) => _idCliente = value;

  String get data => _data??= '';
  set data(String value) => _data = value;

  //endregion

}
