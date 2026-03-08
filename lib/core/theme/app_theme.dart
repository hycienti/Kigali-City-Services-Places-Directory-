import 'package:flutter/material.dart';

/// App theme: dark blue primary, amber accent (matches sample UI).
class AppTheme {
  AppTheme._();
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color accent = Color(0xFFFFB300);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          primary: primaryDark,
          secondary: accent,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: primaryDark,
          selectedItemColor: accent,
          unselectedItemColor: Colors.white70,
        ),
      );
}
