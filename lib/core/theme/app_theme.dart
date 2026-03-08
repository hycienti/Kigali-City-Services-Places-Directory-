import 'package:flutter/material.dart';

/// App theme: dark blue primary, amber accent (matches sample UI).
class AppTheme {
  AppTheme._();
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color accent = Color(0xFFFFB300);

  /// Card corner radius used across cards, map block, and sections.
  static const double cardRadius = 16;
  /// Bottom sheet top corner radius.
  static const double sheetRadius = 24;

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
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: primaryDark,
          selectedItemColor: accent,
          unselectedItemColor: Colors.white70,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
