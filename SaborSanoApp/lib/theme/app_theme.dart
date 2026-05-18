import 'package:flutter/material.dart';

/// Colores y tema de la app.
/// Basado en la paleta de la web (variables.css).
class AppTheme {
  AppTheme._();

  /// Verdes principales / secundarios.
  /// Web:
  /// --color-secondary: #5b7d5b
  /// --color-green-medium: #7aa874
  /// --color-olive-green-dark: #9aab8a
  static const Color accentLime = Color(0xFF7AA874); // medium green
  static const Color accentLimeDark = Color(0xFF5B7D5B); // secondary dark green

  /// Fondos.
  /// --color-olive-green: #f6f7f2 (background claro)
  /// --color-beige: #f5f0e8 (barras / search)
  static const Color surfaceLight = Color(0xFFF6F7F2);
  static const Color surfaceBeige = Color(0xFFF5F0E8);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// Texto.
  /// --color-text-dark: #2f3e2f
  /// --color-text-light: #ffffff
  static const Color textPrimary = Color(0xFF2F3E2F);
  static const Color textSecondary = Color(0xFF7D7D6A); // sage-like

  static const Color chipSelectedBg = accentLimeDark;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: accentLime,
        onPrimary: Colors.white,
        secondary: accentLimeDark,
        onSecondary: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimary,
        background: surfaceLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceBeige,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
