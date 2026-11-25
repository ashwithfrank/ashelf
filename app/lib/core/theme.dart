import 'package:flutter/material.dart';

class AppTheme {
  static const _cream = Color(0xFFF7F2E9);
  static const _ink = Color(0xFF2B2620);
  static const _graphite = Color(0xFF14130F);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final bg = dark ? _graphite : _cream;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8A6A3D),
        brightness: b,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: dark ? _cream : _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            dark ? const Color(0xFF1C1A15) : const Color(0xFFEDE6D6),
      ),
    );
  }
}
