import 'package:delivery/auxiliar/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'import.dart';

class OkiThemeMode {
  static const sistema = 'Sistema';
  static const claro = 'Claro';
  static const escuro = 'Escuro';
}

class OkiTheme {
  static bool darkModeOn = false;

  static Color get primary => OkiColors.primary;
  static Color get primaryDark => OkiColors.primaryLight;
  // static Color get primaryLight => OkiColors.primaryLight;
  static Color get accent => OkiColors.accent;
  static Color get accentLight => OkiColors.accentLight;
  static Color get text => darkModeOn ? OkiColors.textDark : OkiColors.textLight;
  // static Color textInvert([double alfa = 1]) => OkiColors.textInvert(alfa, isDark: darkModeOn);
  static Color get textError => OkiColors.textError;
  static Color get cardColor => darkModeOn ? OkiColors.cardDark : OkiColors.cardLight;
  static Color get background => OkiColors.background(isDark: darkModeOn);
  static Color get tint => OkiColors.tint;

  static Brightness getBrilho(String theme) {
    Brightness brightness;
    if (theme == OkiThemeMode.sistema)
      brightness = SchedulerBinding.instance.window.platformBrightness;
    else if (theme == OkiThemeMode.claro)
      brightness = Brightness.light;
    else
      brightness = Brightness.dark;
    return brightness;
  }
}
