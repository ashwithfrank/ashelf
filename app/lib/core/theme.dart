import 'package:flutter/material.dart';

class AppTheme {
  static const _cream = Color(0xFFF7F2E9);
  static const _ink = Color(0xFF2B2620);
  static const _graphite = Color(0xFF14130F);

  static ThemeData light(Color seed) => _build(Brightness.light, seed, false);
  static ThemeData dark(Color seed, {bool amoled = false}) =>
      _build(Brightness.dark, seed, amoled);

  static ThemeData _build(Brightness b, Color seed, bool amoled) {
    final dark = b == Brightness.dark;
    final bg = dark ? (amoled ? Colors.black : _graphite) : _cream;
    final bar = dark
        ? (amoled ? const Color(0xFF0A0A0A) : const Color(0xFF1C1A15))
        : const Color(0xFFEDE6D6);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: b),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: dark ? _cream : _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: bar),
    );
  }
}
