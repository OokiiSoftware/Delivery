import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<InfoPage> {

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText(Titles.INFORMACOES_PAGE)),
      body: Center(
        child: _appInfo(),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _appInfo() {
    var dividerP = Padding(padding: EdgeInsets.only(top: 10, right: 5));
    var dividerG = SizedBox(height: 30);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Icone
          Image.asset(OkiIcons.ic_launcher,
            width: 130,
            height: 130,
          ),
          dividerG,
          OkiText('${AppResources.APP_NAME}'),
          dividerP,
          OkiText('${Strings.VERSAO} : ${Aplication.packageInfo.version}'),
          dividerG,
          OkiText(Strings.CONTATOS),
          dividerP,
          GestureDetector(
            child: Text(AppResources.app_email, style: TextStyle(
                color: OkiTheme.accent, fontSize: Config.fontSize)),
            onTap: () {
              Aplication.openEmail(AppResources.app_email);
            },
          ),
          dividerG,
          OkiText(Strings.POR),
          dividerP,
          Tooltip(
            message: AppResources.company_name,
            child: Image.asset(OkiIcons.ic_oki_logo,
              width: 80,
              height: 80,
            ),
          ),
        ]);
  }

  //endregion

}