import 'dart:io';
import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final BuildContext context;
  LoginPage(this.context);
  @override
  State<StatefulWidget> createState() => _State(context);
}
class _State extends State<LoginPage> {

  //region Variaveis

  static const String TAG = 'LoginPage';
  final BuildContext context;

  bool _inProgress = false;

  //endregion

  _State(this.context);

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OkiTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(OkiIcons.ic_launcher_adaptive, width: 200),
            Padding(padding: EdgeInsets.only(top: 10)),
            if (Platform.isAndroid)
              GestureDetector(
                child: Container(
                  width: 270,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(
                        width: 1.5,
                        color: Colors.blue,
                      )
                  ),
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(5),
                        child: Image.asset(OkiIcons.ic_google),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Login com Google', style: TextStyle(color: Colors.white, fontSize: 20)),
                      )
                    ],
                  ),
                ),
                onTap: onLoginWithGoogleButtonPressed,
              )
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  void onLoginWithGoogleButtonPressed() async {
    _setInProgress(true);
    try{
      Log.d(TAG, 'Login com Google');
      await FirebaseOki.googleAuth();
      Log.d(TAG, 'Login com Google', 'OK');
      await _onLoginSuccess();
    } catch (e) {
      Log.e(TAG, 'Login com Google Fail', e);
      Log.snack('Login with Google fails');
    }
    _setInProgress(false);
  }

  Future<void> _onLoginSuccess() async {
    Admin.inst.init();

    var user = await UserOki.baixarUser(FirebaseOki.user.uid);
    if (user == null) {
      var userTemp = UserDados(FirebaseOki.user);
      userTemp.salvar();
      FirebaseOki.init();
    } else {
      FirebaseOki.userOki = user;
      FirebaseOki.checkUserSpecialAccess();
      Preferences.setObj(PreferencesKey.USER, user.toJson());
    }

    Preferences.setBool(PreferencesKey.USER_LOGADO, true);
    Navigator.pop(context, true);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}