import 'import.dart';
import 'package:delivery/model/import.dart';

class Funcionarios {
  static const TAG = 'Funcionarios';

  static Funcionarios instance = Funcionarios();

  Map<String, UserOki> users = Map();
  Map<String, UserOki> data = Map();

  void add(UserOki item) {
    data[item.dados.id] = item;
  }

  void remove(UserOki item) {
    data.remove(item.dados.id);
  }

  UserOki get(String id) {
    return data[id];
  }

  UserOki getUser(String idOrEmail) {
    for (var value in users.values) {
      if (value.dados.email == idOrEmail || value.dados.id == idOrEmail)
        return value;
    }
    return null;
  }

  Future<bool> save() async {
    return await Preferences.setObj(PreferencesKey.FUNCIONARIOS, toMap());
  }

  Future<bool> load() async {
    var dataTemp = Preferences.getObj(PreferencesKey.FUNCIONARIOS);
    if (dataTemp  == null)
      return true;
    var temp = UserOki.fromJsonList(dataTemp);
    if (temp != null)
      data = temp;
    Log.d(TAG, 'load', 'OK');
    return true;
  }

  Future<Map<String, UserOki>> baixar() async {
    try {
      var result1 = await FirebaseOki.database
          .child(FirebaseChild.ACESSO_ESPECIAL)
          .once();

      Map<dynamic, dynamic> acessos = result1.value;
      if (acessos == null)
        return data;

      var result = await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .once();

      var temp = UserOki.fromJsonList(result.value);
      if (temp != null) {
        users = temp;
        temp.forEach((key, value) {
          if (acessos.containsKey(key)) {
            if (acessos[key] != 0)
              data[key] = value..setSpecialAcesso(acessos[key], save: false);
            else
              data.remove(key);
          }
        });
      }
    } catch(e) {
      Log.e(TAG, 'baixar', e);
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    data.forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }

}