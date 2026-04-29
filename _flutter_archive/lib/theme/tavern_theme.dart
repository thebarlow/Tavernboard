import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class TavernColors {
  static const Color background = Color(0xFF2C1A0E);
  static const Color surface = Color(0xFF3D2512);
  static const Color surfaceElevated = Color(0xFF4E3220);
  static const Color accent = Color(0xFFC8860A);
  static const Color accentSecondary = Color(0xFF8B4513);
  static const Color textPrimary = Color(0xFFF5E6C8);
  static const Color textSecondary = Color(0xFFC9A96E);
  static const Color divider = Color(0xFF5C3D1E);
  static const Color error = Color(0xFFC0392B);
  static const Color success = Color(0xFF27AE60);
}

abstract final class TavernTheme {
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: TavernColors.background,
      colorScheme: const ColorScheme.dark(
        primary: TavernColors.accent,
        secondary: TavernColors.accentSecondary,
        surface: TavernColors.surface,
        error: TavernColors.error,
        onPrimary: TavernColors.background,
        onSecondary: TavernColors.textPrimary,
        onSurface: TavernColors.textPrimary,
        onError: TavernColors.textPrimary,
      ),
      dividerColor: TavernColors.divider,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: TavernColors.surface,
        foregroundColor: TavernColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
          color: TavernColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardTheme(
        color: TavernColors.surface,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TavernColors.surfaceElevated,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: TavernColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: TavernColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: TavernColors.accent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: TavernColors.error),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: TavernColors.error, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: GoogleFonts.lora(color: TavernColors.textSecondary),
        hintStyle: GoogleFonts.lora(color: TavernColors.textSecondary),
        errorStyle: GoogleFonts.lora(color: TavernColors.error, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TavernColors.accent,
          foregroundColor: TavernColors.background,
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TavernColors.accent,
          side: const BorderSide(color: TavernColors.accent),
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TavernColors.surfaceElevated,
        contentTextStyle: GoogleFonts.lora(color: TavernColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: TavernColors.surface,
        titleTextStyle: GoogleFonts.cinzel(
          color: TavernColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.lora(
          color: TavernColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.cinzel(color: TavernColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.lora(color: TavernColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.lora(color: TavernColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.lora(color: TavernColors.textPrimary, fontSize: 16),
      bodyMedium: GoogleFonts.lora(color: TavernColors.textPrimary, fontSize: 14),
      bodySmall: GoogleFonts.lora(color: TavernColors.textSecondary, fontSize: 12),
      labelLarge: GoogleFonts.lora(color: TavernColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.lora(color: TavernColors.textSecondary, fontSize: 12),
      labelSmall: GoogleFonts.lora(color: TavernColors.textSecondary, fontSize: 11),
    );
  }
}
