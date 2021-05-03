import 'package:delivery/auxiliar/import.dart';
import 'package:delivery/model/import.dart';
import 'package:delivery/res/import.dart';
import 'package:flutter/material.dart';

class Log {
  static const _APP_NAME = 'DeliveryApp';
  static final scaffKey = GlobalKey<ScaffoldState>();

  static void snack(String texto, {bool isError = false, String actionLabel = '', Function() actionClick}) {
    try {
      scaffKey.currentState.hideCurrentSnackBar();

      var textColor = Colors.white;
      var snack = SnackBar(
        content: Container(
          // margin: Layouts.adsPadding(0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isError ? Icons.clear : Icons.check, color: textColor),
              SizedBox(width: 12.0),
              Text(texto, style: TextStyle(color: textColor, fontSize: 17)),
            ],
          ),
        ),
        backgroundColor: isError ? Colors.red : OkiTheme.accent,
        action: actionClick == null ?
        SnackBarAction(
          label: 'X',
          textColor: textColor,
          onPressed: () {
            scaffKey.currentState.hideCurrentSnackBar();
          },
        ) :
        SnackBarAction(
          label: actionLabel,
          textColor: textColor,
          onPressed: actionClick,
        ),
      );
      scaffKey.currentState.showSnackBar(snack);
    } catch (e) {
      e('Log', 'snackbar', e);
    }
  }

  static void d(String tag, String metodo, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = '';
    if (value != null) msg += value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    if (!Aplication.isRelease)
      print('$_APP_NAME D: $tag: $metodo: $msg');
  }
  static void e(String tag, String metodo, dynamic e, {bool send = false}) {
    String msg = e.toString();
    if (!Aplication.isRelease)
      print('$_APP_NAME E: $tag: $metodo: $msg');

    if (send)
      _sendError(tag, metodo, msg);
  }

  static void test(String tag) {
    if (!Aplication.isRelease)
      print(tag + ": Teste");
  }

  static _sendError(String tag, String metodo, String value) {
    String id = '';
    if (FirebaseOki.isLogado)
      id = FirebaseOki.user.uid;

    Erro e = Erro();
    e.data = DataHora.now();
    e.classe = tag;
    e.metodo = metodo;
    e.valor = value;
    e.userId = id;
   e.salvar();
  }
}