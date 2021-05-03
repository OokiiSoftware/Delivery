import 'import.dart';
import 'package:delivery/res/import.dart';

class Config {
  static int _currentCapitulo;
  static double _fontSize;
  static String _livro;
  static String _autorName;
  static String _theme;
  static String _ultimoBackup;
  static String _bibliaVersion;
  static bool _autoBackup;

  static const String _inicialLivro = 'Gn';
  static const String bibliaLocalVersion = 'acf';

  //region get set

  static String get theme => _theme;
  static set theme(String value) {
    _theme = value;
    Preferences.setString(PreferencesKey.THEME, _theme);
  }
  static String get autorName => _autorName;
  static set autorName(String value) {
    _autorName = value;
    // Preferences.setString(PreferencesKey.AUTOR_NAME, _autorName);
  }

  static int get currentCapitulo => _currentCapitulo;
  static set currentCapitulo(int value) {
    _currentCapitulo = value -1;
    Preferences.setInt(PreferencesKey.CURRENT_CAPITULO, _currentCapitulo);
  }

  static double get fontSize => _fontSize;
  static set fontSize(double value) {
    _fontSize = value;
    Preferences.setDouble(PreferencesKey.FONTE_SIZE, value);
  }

  static String get livro => _livro ?? _inicialLivro;
  static set livro(String value) {
    _livro = value;
    Preferences.setString(PreferencesKey.LIVRO, value);
  }

  static String get ultimoBackup => _ultimoBackup ?? '';
  static set ultimoBackup(String value) {
    _ultimoBackup = value;
    Preferences.setString(PreferencesKey.ULTIMO_BACKUP, value);
  }

  static String get bibliaVersion => _bibliaVersion ?? bibliaLocalVersion;
  static set bibliaVersion(String value) {
    _bibliaVersion = value;
    Preferences.setString(PreferencesKey.BIBLIA_VERSION, value);
  }

  static bool get autoBackup => _autoBackup ?? true;
  static set autoBackup(bool value) {
    _autoBackup = value;
    Preferences.setBool(PreferencesKey.AUTO_BACKUP, value);
  }

  //endregion

  static void load() {
    _fontSize = Preferences.getDouble(PreferencesKey.FONTE_SIZE, padrao: 16);
    _currentCapitulo = Preferences.getInt(PreferencesKey.CURRENT_CAPITULO, padrao: 1);
    _livro = Preferences.getString(PreferencesKey.LIVRO, padrao: _inicialLivro);
    _theme = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);
    // _autorName = Preferences.getString(PreferencesKey.AUTOR_NAME, padrao: '');
    _ultimoBackup = Preferences.getString(PreferencesKey.ULTIMO_BACKUP, padrao: 'Nenhum');
    _bibliaVersion = Preferences.getString(PreferencesKey.BIBLIA_VERSION, padrao: bibliaLocalVersion);
    _autoBackup = Preferences.getBool(PreferencesKey.AUTO_BACKUP, padrao: true);
    PesquisaFiltro._load();
  }
}

class PesquisaType {
  static const int tudoValue = 0;
  static const int antigoTestamentoValue = 1;
  static const int novoTestamentoValue = 2;
  static const int somenteValue = 3;

  static PesquisaType get antigoTestamento => PesquisaType(antigoTestamentoValue);
  static PesquisaType get novoTestamento => PesquisaType(novoTestamentoValue);
  static PesquisaType get tudo => PesquisaType(tudoValue);
  static PesquisaType get somente => PesquisaType(somenteValue);

  PesquisaType(this.value);
  int value;

  static List<String> toList() {
    return ['Tudo', 'AntigoTestamento', 'NovoTestamento', 'Somente'];
  }

  @override
  String toString() {
    return toList()[value];
  }

  bool get isNovoTestamento => value == novoTestamento.value;
  bool get isAntigoTestamento => value == antigoTestamento.value;
  bool get isTudo => value == tudo.value;
  bool get isSomente => value == somente.value;
}

class PesquisaFiltro {
  static int _pesquisaType = PesquisaType.tudoValue;
  static String _livro = 'Gênesis';

  static int get pesquisaType => _pesquisaType;
  static set pesquisaType(int value) {
    _pesquisaType = value;
    Preferences.setInt(PreferencesKey.PESQUISA_TYPE, value);
  }

  static String get livro => _livro ?? 'Gênesis';
  static set livro(String value) {
    _livro = value;
    // Preferences.setString(PreferencesKey.PESQUISA_LIVRO, value);
  }

  static void _load() {
    _pesquisaType = Preferences.getInt(PreferencesKey.PESQUISA_TYPE, padrao: PesquisaType.tudoValue);
    // _livro = Preferences.getString(PreferencesKey.PESQUISA_LIVRO, padrao: 'Gênesis');
  }
}

class RunTime {

}
