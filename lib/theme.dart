import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF007AA3);
  static const Color accent = Color(0xFF00B4D8);
  static const Color headerBg = Color(0xFF081C2D);
  static const Color surface = Color(0xFFF6F9FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B7A8F);

  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: primary,
      colorScheme: base.colorScheme.copyWith(primary: primary, secondary: accent, surface: card),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(backgroundColor: headerBg, elevation: 0, surfaceTintColor: headerBg),
      cardTheme: CardThemeData(
        elevation: 3,
        color: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primary)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F2435),
        hintStyle: const TextStyle(color: Color(0xFFB0C6D6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.copyWith(
        bodyMedium: const TextStyle(color: Color(0xFF334155)),
        titleLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
