import 'package:flutter/material.dart';

class AppTheme {
  // Brand
  static const Color primary       = Color(0xFF0091DA); // bright Cisco blue
  static const Color primaryDark   = Color(0xFF006EA6);
  static const Color accent        = Color(0xFF00D1FF); // cyan
  static const Color accentSoft    = Color(0xFFD9F1FA);

  // Header gradient
  static const Color headerDeep    = Color(0xFF031A33);
  static const Color headerMid     = Color(0xFF0A2B4A);
  static const Color headerBg      = headerDeep; // legacy alias

  // Neutrals
  static const Color surface       = Color(0xFFF3F6FB);
  static const Color card          = Color(0xFFFFFFFF);
  static const Color muted         = Color(0xFF64748B);
  static const Color border        = Color(0xFFE7ECF3);
  static const Color subtleSurface = Color(0xFFF7FAFD);

  // Semantic
  static const Color success       = Color(0xFF16A34A);
  static const Color warning       = Color(0xFFEF9F1A);
  static const Color danger        = Color(0xFFE53935);

  // Radii
  static const double radiusCard   = 20;
  static const double radiusButton = 14;
  static const double radiusPill   = 999;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerDeep, headerMid],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accent],
  );

  static List<BoxShadow> softShadow({double blur = 20, double y = 8}) => [
        BoxShadow(
          color: const Color(0xFF0F1F3B).withValues(alpha: 0.08),
          blurRadius: blur,
          offset: Offset(0, y),
        ),
      ];

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: card,
      onSurface: const Color(0xFF0F172A),
      error: danger,
    );

    return base.copyWith(
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: headerDeep,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton)),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton)),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: accentSoft,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusButton),
            borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusButton),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusButton),
            borderSide: const BorderSide(color: primary, width: 1.4)),
      ),
      dividerTheme: const DividerThemeData(
          color: border, space: 1, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4),
        headlineSmall: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2),
        titleLarge: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Color(0xFF0F172A)),
        titleMedium: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF0F172A)),
        bodyLarge: const TextStyle(
            fontSize: 14, color: Color(0xFF0F172A), height: 1.4),
        bodyMedium: const TextStyle(
            fontSize: 13, color: Color(0xFF334155), height: 1.4),
        bodySmall: const TextStyle(
            fontSize: 12, color: muted, height: 1.4),
        labelLarge: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }
}
