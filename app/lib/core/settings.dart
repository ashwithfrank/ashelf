import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences, saved on the device.
class Settings extends ChangeNotifier {
  Settings._();
  static final instance = Settings._();

  static const accents = <Color>[
    Color(0xFF8A6A3D), // brown (default)
    Color(0xFF2A8C50), // green
    Color(0xFF3B6FD4), // blue
    Color(0xFF8E4FC8), // purple
    Color(0xFFC2543C), // red
    Color(0xFF1F8A8A), // teal
  ];

  late SharedPreferences _p;
  ThemeMode themeMode = ThemeMode.system;
  int accent = 0;
  bool amoled = false;
  bool openInApp = true;
  bool nightPdf = false;
  bool autoUpdate = true;
  int lastUpdateCheck = 0;

  Color get accentColor => accents[accent];

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values[(_p.getInt('themeMode') ?? 0).clamp(0, 2).toInt()];
    accent = (_p.getInt('accent') ?? 0).clamp(0, accents.length - 1).toInt();
    amoled = _p.getBool('amoled') ?? false;
    openInApp = _p.getBool('openInApp') ?? true;
    nightPdf = _p.getBool('nightPdf') ?? false;
    autoUpdate = _p.getBool('autoUpdate') ?? true;
    lastUpdateCheck = _p.getInt('lastUpdateCheck') ?? 0;
  }

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    _p.setInt('themeMode', m.index);
    notifyListeners();
  }

  void setAccent(int i) {
    accent = i;
    _p.setInt('accent', i);
    notifyListeners();
  }

  void setAmoled(bool v) {
    amoled = v;
    _p.setBool('amoled', v);
    notifyListeners();
  }

  void setOpenInApp(bool v) {
    openInApp = v;
    _p.setBool('openInApp', v);
    notifyListeners();
  }

  void setNightPdf(bool v) {
    nightPdf = v;
    _p.setBool('nightPdf', v);
    notifyListeners();
  }

  void setAutoUpdate(bool v) {
    autoUpdate = v;
    _p.setBool('autoUpdate', v);
    notifyListeners();
  }

  void markUpdateChecked() {
    lastUpdateCheck = DateTime.now().millisecondsSinceEpoch;
    _p.setInt('lastUpdateCheck', lastUpdateCheck);
  }
}
