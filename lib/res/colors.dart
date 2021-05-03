import 'package:flutter/material.dart';

class OkiColors {
  static int cor(bool darkModeOn) => darkModeOn ? 0 : 255;

  static Color get primary => Colors.orange; // Color.fromARGB(255, 62, 62, 62);
  static Color get primaryLight => Colors.orange[500];
  static Color get launcherIconBacgground => Color.fromARGB(255, 62, 62, 62);
  static Color accent = Colors.deepOrange;
  static Color accentLight = Colors.deepOrangeAccent;
  static Color textDark = Colors.white;
  static Color textLight = Colors.black;
  static Color get cardLight => Colors.black12;
  static Color get cardDark => Colors.black45;
  static Color textInvert(double alfa, {bool isDark = false}) => Color.fromRGBO(cor(isDark), cor(isDark), cor(isDark), alfa);
  static Color textError = Colors.red;
  static Color background({bool isDark = false}) => isDark ? Colors.black87 : Colors.white;
  static Color tint = Colors.white;
}

class MarkerColors {
  static const Color green = Colors.green;
  static const Color cyan = Colors.cyan;
  static const Color pink = Colors.pink;
  static const Color orange = Colors.orange;
  static const Color purple = Colors.purpleAccent;
}
