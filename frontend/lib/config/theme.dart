import 'package:flutter/material.dart';

enum ThemeColor { white, black, blue, green }

class AppTheme {
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color blueAccent = Color(0xFF4A90D9);
  static const Color greenAccent = Color(0xFF4CAF50);

  // Dark (Black) theme colors
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);
  static const Color darkTextPrimary = Color(0xFFEAEAEA);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // White theme colors
  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF666666);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);

  // Mutable fields updated by getTheme() as a side effect when theme switches.
  // ThemeProvider.notifyListeners() triggers Consumer<ThemeProvider> in main.dart,
  // which rebuilds MaterialApp and the entire widget tree, so these values are
  // always fresh when widgets read them via AppTheme.textPrimary etc.
  static Color textPrimary = darkTextPrimary;
  static Color textSecondary = darkTextSecondary;
  static Color surfaceColor = darkSurface;
  static Color cardColor = darkCard;
  static Color primaryColor = darkBg;

  static ThemeData getTheme(ThemeColor color) {
    switch (color) {
      case ThemeColor.white:
        return _buildLightTheme();
      case ThemeColor.black:
        return _buildDarkTheme(AppTheme.accentColor, darkBg, darkSurface, darkCard);
      case ThemeColor.blue:
        return _buildDarkTheme(AppTheme.blueAccent, const Color(0xFF0A1929), const Color(0xFF102A43), const Color(0xFF1A3A5C));
      case ThemeColor.green:
        return _buildDarkTheme(AppTheme.greenAccent, const Color(0xFF0D1F0D), const Color(0xFF142814), const Color(0xFF1A331A));
    }
  }

  static ThemeData _buildLightTheme() {
    primaryColor = lightBg;
    surfaceColor = lightSurface;
    cardColor = lightCard;
    textPrimary = lightTextPrimary;
    textSecondary = lightTextSecondary;

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightBg,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: accentColor,
        secondary: accentColor,
        surface: lightSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData _buildDarkTheme(Color accent, Color bg, Color surface, Color card) {
    primaryColor = bg;
    surfaceColor = surface;
    cardColor = card;
    textPrimary = darkTextPrimary;
    textSecondary = darkTextSecondary;

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: bg,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}