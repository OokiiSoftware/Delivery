import 'import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/pages/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class Aplication {
  static const String TAG = 'Aplication';

  static int appVersionInDatabase = 0;
  static PackageInfo packageInfo;
  static Estabelecimento estabelecimento;

  static bool get isRelease => bool.fromEnvironment('dart.vm.product');
  static Locale get locale => Locale('pt', 'BR');

  static Future<void> init() async {
    Log.d(TAG, 'init', 'iniciando');

    try {
      await FirebaseOki.init();
    } catch(e) {
      Log.e(TAG, 'init FirebaseOki', e, send: true);
    }

    try {
      await Preferences.init();
    } catch(e) {
      Log.e(TAG, 'init Preferences', e, send: true);
    }

    try {
      await Pedidos.instance.load();
    } catch(e) {
      Log.e(TAG, 'init Pedidos', e, send: true);
    }

    try {
      await Funcionarios.instance.load();
    } catch(e) {
      Log.e(TAG, 'init Funcionarios', e, send: true);
    }

    try {
      Admin.inst.init();
    } catch(e) {
      Log.e(TAG, 'init Admin', e, send: true);
    }

    try {
      Config.load();
    } catch(e) {
      Log.e(TAG, 'init Config', e, send: true);
    }

    packageInfo = await PackageInfo.fromPlatform();

    Log.d(TAG, 'init', 'OK');
  }

  static void setOrientation(List<DeviceOrientation> orientacoes) {
    SystemChrome.setPreferredOrientations(orientacoes);
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    int _value = await FirebaseOki.database
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) => value.value)
        .catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return -1;
    });
    // String url;

    Log.d(TAG, 'buscarAtualizacao', 'Web Version', _value, 'Local Version', packageInfo.buildNumber);
    appVersionInDatabase = _value;
    int appVersion = int.parse(packageInfo.buildNumber);

    if (_value > appVersion) {
      // url = FirebaseOki.userOki;
    }

    return null;
  }

  static Future<bool> openUrl(String url) async {
    try {
      await launch(url);
      return true;
    } catch(e) {
      Log.snack(MyErros.ABRIR_LINK, isError: true);
      Log.e(TAG, 'openUrl', e);
      return false;
    }
  }

  static void openEmail(String email) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: '$email',
        queryParameters: {
          'subject': 'Delivery_App'
        }
    );
    try {
      await launch(_emailLaunchUri.toString());
    } catch(e) {
      Log.snack(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openWhatsApp(String numero) async {
    try {
      numero = numero.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');
      var link ="whatsapp://send?phone=55$numero";
        await launch(Uri.encodeFull(link));
    } catch(e) {
      Log.snack(MyErros.ABRIR_WHATSAPP, isError: true);
      Log.e(TAG, 'openWhatsApp', e);
    }
  }

  static Future<File> openCropImage(BuildContext context, {double aspect}) async {
    var result = await Navigate.to(context, CropImagePage(aspect));

    if (result != null && result is File) {
      Log.d(TAG, 'openCropImage', 'OK', result.path);
      return result;
    } else {
      Log.d(TAG, 'openCropImage', 'Error');
    }
    return null;
  }

  static Future<bool> checkLogin(BuildContext context) async {
    if (FirebaseOki.userOki == null) {
      var title = 'Login';
      var content = [
        OkiText('Você precisa estar logado para realizar essa ação.'),
        OkiText('Deseja fazer login agora?'),
      ];
      var result = await DialogBox.simNao(context, title: title, content: content);
      if (result.isPositive) {
        var result = await Navigate.to(context, LoginPage(context));
        if (result == null || !(result is bool) || !result)
          return false;
      } else
        return false;
    }
    return true;
  }

}