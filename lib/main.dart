import 'package:delivery/model/estabelecimento.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'auxiliar/import.dart';
import 'pages/import.dart';
import 'res/import.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<Main> {

  //region variaveis
  // static const TAG = 'Main';
  bool _isIniciado = false;
  bool _isEstabelecimentoFechado = false;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    _testes();

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: setTheme,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppResources.APP_NAME,
          theme: theme,
          home: _getBody,
          builder: (c, widget) => Scaffold(
              key: Log.scaffKey,
              body: widget
          ),
        );
      },
    );
  }

  //endregion

  //region metodos

  void _init() async {
    loadTheme();
    await Aplication.init();
    _loadEstabelecimento();
    _setIniciado(true);
  }

  Widget get _getBody {
    if (_isEstabelecimentoFechado)
      return ScreenLojaFechada();
    if (_isIniciado)
      return MainPage();
    else
      return SplashScreen();
  }

  ThemeData setTheme(Brightness brightness) {
    bool darkModeOn = brightness == Brightness.dark;
    OkiTheme.darkModeOn = darkModeOn;

    return ThemeData(
      brightness: brightness,
      primaryColor: OkiTheme.primary,
      accentColor: OkiTheme.accent,
      primaryIconTheme: IconThemeData(color: OkiTheme.tint),
      tabBarTheme: TabBarTheme(
          labelColor: OkiTheme.tint,
          unselectedLabelColor: OkiTheme.tint
      ),
      tooltipTheme: TooltipThemeData(
          textStyle: Styles.appBarText,
          decoration: BoxDecoration(
              color: OkiTheme.primary
          )
      ),
      backgroundColor: OkiTheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        bodyText2: TextStyle(fontSize: 14),
      ),
    );
  }

  void _loadEstabelecimento() async {
    var temp = Preferences.getObj(PreferencesKey.ESTABELECIMENTO_DADOS);
    if (temp != null) {
      try {
        Aplication.estabelecimento = Estabelecimento.fromJson(temp);
      } catch(e) {

      }
    }

    temp = await Estabelecimento.baixar();
    if (temp != null) {
      Aplication.estabelecimento = temp;
      Preferences.setObj(PreferencesKey.ESTABELECIMENTO_DADOS, Aplication.estabelecimento.toJson());
    }
  }

  void loadTheme() async {
    Preferences.instance = await SharedPreferences.getInstance();
    var savedTheme = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);

    Brightness brightness = OkiTheme.getBrilho(savedTheme);
    setTheme(brightness);
  }

  void _setIniciado(bool b) {
    if(!mounted) return;
    setState(() {
      _isIniciado = b;
    });
  }

  void _testes() {
    DateTime date = DateTime.now();
    // Log.d(TAG, '_testes', date.weekday);
    switch(date.weekday) {
      case DateTime.friday:
        _isEstabelecimentoFechado = date.hour >= 18;
        break;
      case DateTime.saturday:
        _isEstabelecimentoFechado = date.hour <= 18;
        break;
      default:
        _isEstabelecimentoFechado = false;
        break;
    }
  }

  //endregion

}
