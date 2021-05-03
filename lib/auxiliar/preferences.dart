import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logs.dart';

class Preferences {
  static SharedPreferences instance;
  dynamic get(String key) => instance.get(key);

  static int getInt(String key, {int padrao = 0}) => instance.getInt(key) ?? padrao;
  static bool getBool(String key, {bool padrao = false}) => instance.getBool(key) ?? padrao;
  static String getString(String key, {String padrao = ''}) => instance.getString(key) ?? padrao;
  static double getDouble(String key, {double padrao = 0.0}) => instance.getDouble(key) ?? padrao;
  static dynamic getObj(String key) {
    var temp = getString(key);
    if (temp.isEmpty)
      return null;
    return jsonDecode(temp);
  }

  static Future<bool> setInt(String key, int value) async => await instance.setInt(key, value);
  static Future<bool> setBool(String key, bool value) async => await instance.setBool(key, value);
  static Future<bool> setDouble(String key, double value) async => await instance.setDouble(key, value);
  static Future<bool> setString(String key, String value) async => await instance.setString(key, value);
  static Future<bool> setObj(String key, dynamic value) async => await setString(key, jsonEncode(value));

  static bool containsKey(String key) => instance.containsKey(key);

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
    Log.d('Preferences', 'init', 'OK');
  }
}

class PreferencesKey {
  static const String EMAIL = "email";
  static const String PESQUISA_TYPE = "PESQUISA_TYPE";
  static const String PEDIDOS = "PEDIDOS";
  static const String ULTIMO_TUTORIAL_OK = "ULTIMO_TUTORIAL_01";
  static const String TUTORIAL_POSITION = "TUTORIAL_POSITION_";
  static const String UPDATE_NOTIFICATION = "UPDATE_NOTIFICATION_1";
  static const String USER_LOGADO = "USER_LOGADO";
  static const String USER = "USER";
  static const String MSG_DE_TESTES = "MSG_DE_TESTES";
  static const String THEME = "THEME";
  static const String CONFIG_SHOW_INFO = "CONFIG_SHOW_INFO";
  static const String ABRIR_CONFIG_PAGE = "ABRIR_CONFIG_PAGE";
  static const String PRODUTOS = "PRODUTOS";
  static const String AUTO_BACKUP = "AUTO_BACKUP";
  static const String ULTIMO_BACKUP = "ULTIMO_BACKUP";
  static const String BIBLIA_VERSION = "BIBLIA_VERSION";
  static const String NOVIDADES = "NOVIDADES_01";
  static const String AVISO_BAIXAR_ESTUDO = "AVISO_BAIXAR_ESTUDO_2";
  static const String FUNCIONARIOS = "FUNCIONARIOS";
  static const String ESTABELECIMENTO_DADOS = "ESTABELECIMENTO_DADOS";

  static const String LIVRO = 'LIVRO';
  static const String TUTORIAL = 'tutorial_01';
  static const String ITEM_LIST_MODE = 'itemListMode';
  static const String CURRENT_CAPITULO = 'CURRENT_TAB_IN_MAIN_PAGE';
  static const String FONTE_SIZE = 'FONTE_SIZE';
  static const String GENEROS = 'generos';

  static const String POST_AVANCADO = "POST_AVANCADO";
}
