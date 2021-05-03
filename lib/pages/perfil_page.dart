import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';

class PerfilPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PerfilPage> {

  //region Variaveis
  static const String TAG = 'PerfilPage';

  bool _inProgress = false;

  bool bairroIsEmpty = false;
  bool ruaIsEmpty = false;
  bool numeroIsEmpty = false;
  bool nomeIsEmpty = false;

  //region TextEditingController
  TextEditingController _nome = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _cidade = TextEditingController();
  TextEditingController _bairro = TextEditingController();
  TextEditingController _rua = TextEditingController();
  TextEditingController _numero = TextEditingController();
  TextEditingController _complemento = TextEditingController();
  //endregion

  UserOki userOki = FirebaseOki.userOki;
  User user = FirebaseOki.user;

  //endregion

  //region overrides

  @override
  void initState() {
    try {
      //region variaveis
      var dados = userOki.dados;

      String nome = dados.nome;
      String foto = dados.foto;
      String email = dados.email;
      if (nome.isEmpty) nome = user.displayName ?? '';
      if (foto.isEmpty) foto = user.photoURL ?? '';
      if (email.isEmpty) email = user.email ?? '';

      _nome.text = nome;
      _email.text = email;

      var end = dados.endereco;

      _cidade.text = 'Joselândia';

      _bairro.text = end.bairro;
      _rua.text = end.rua;
      _numero.text = end.numero;
      _complemento.text = end.complemento;
      //endregion
    } catch(e) {
      Log.e(TAG, 'initState', e);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText(Titles.MEU_PERFIL),
        actions: [
          FlatButton(
            child: Text(
                Strings.SALVAR,
                style: TextStyle(fontWeight: FontWeight.bold)
            ),
            textColor: Colors.white,
            onPressed: !_inProgress ? () {
              _salvarUserManager();
            } : null,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            // Nome
            OkiTextField(
              label: Strings.NOME,
              controller: _nome,
              valueIsEmpty: nomeIsEmpty,
              onTap: () {
                setState(() {
                  nomeIsEmpty = false;
                });
              },
            ),
            // Email
            OkiTextField(
              label: Strings.EMAIL,
              controller: _email,
              readOnly: true,
            ),

            // Endereco

            // Cidade
            OkiTextField(
              label: Strings.CIDADE,
              controller: _cidade,
              readOnly: true,
            ),
            // Bairro
            OkiTextField(
              label: Strings.BAIRRO,
              controller: _bairro,
              valueIsEmpty: bairroIsEmpty,
              onTap: () {
                setState(() {
                  bairroIsEmpty = false;
                });
              },
            ),
            // Rua
            OkiTextField(
              label: Strings.RUA,
              controller: _rua,
              valueIsEmpty: ruaIsEmpty,
                onTap: () {
                  setState(() {
                    ruaIsEmpty = false;
                  });
                }
            ),
            // Numero
            OkiTextField(
              label: Strings.NUMERO,
              controller: _numero,
              valueIsEmpty: numeroIsEmpty,
              onTap: () {
                setState(() {
                  numeroIsEmpty = false;
                });
              },
            ),
            // Complemento
            OkiTextField(
              label: Strings.COMPLEMENTO,
              controller: _complemento,
            ),

            Divider(),
            OkiFlatButton(
              text: 'Logout',
              onPressed: _onLogout,
            )
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  void _salvarUserManager() async {
    _setInProgress(true);
    _resetErros();

    var dados = _criarUser();
    if (_verificarDados(dados)) {
      if (await dados.salvar()) {
        userOki.dados = dados;
        Preferences.setObj(PreferencesKey.USER, userOki.toJson());
        Log.snack('Dados Salvos');
      } else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
    }

    _setInProgress(false);
  }

  void _resetErros() {
    if(!mounted) return;
    setState(() {
      ruaIsEmpty =
      numeroIsEmpty = false;
    });
  }

  void _onLogout() async {
    var title = 'Deseja sair de sua conta?';
    var result = await DialogBox.simNao(context, title: title);
    if (!result.isPositive)
      return;
    _setInProgress(true);
    await FirebaseOki.finalize();
    Navigator.pop(context);
  }

  UserDados _criarUser() {
    UserDados dados = UserDados(user);
    dados.nome = _nome.text;
    dados.endereco.cidade = _cidade.text;
    dados.endereco.bairro = _bairro.text;
    dados.endereco.rua = _rua.text;
    dados.endereco.numero = _numero.text;
    dados.endereco.complemento = _complemento.text;
    dados.endereco.estado = 'Maranhão';

    return dados;
  }

  bool _verificarDados(UserDados dados)  {
    try {
      var end = dados.endereco;

      ruaIsEmpty = end.rua.isEmpty;
      nomeIsEmpty = dados.nome.isEmpty;
      numeroIsEmpty = end.numero.isEmpty;
      bairroIsEmpty = end.bairro.isEmpty;
      setState(() {});

      if (ruaIsEmpty) throw('');
      if (nomeIsEmpty) throw('');
      if (numeroIsEmpty) throw('');
      if (bairroIsEmpty) throw('');
      return true;
    } catch(e) {
      HapticFeedback.lightImpact();
      return false;
    }
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
