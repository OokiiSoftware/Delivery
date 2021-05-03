import 'package:delivery/auxiliar/import.dart';
import 'package:flutter/material.dart';
import 'import.dart';

class Styles {
  // static TextStyle text = TextStyle(color: OkiTheme.text);
  static TextStyle get appBarText => TextStyle(color: Colors.white);
  static TextStyle get normalText => TextStyle(color: OkiTheme.text, fontSize: Config.fontSize);
  static TextStyle get titleText => TextStyle(color: OkiTheme.text, fontSize: Config.fontSize + 5);
  static TextStyle get textEror => TextStyle(color: OkiTheme.textError, fontSize: Config.fontSize);

  static BoxDecoration get decoration => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0.5, 0.5),
        blurRadius: 3.0,
      ),
    ],
  );
}
