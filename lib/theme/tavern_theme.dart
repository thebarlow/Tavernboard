import 'package:flutter/material.dart';

class TavernTheme {
  TavernTheme._();

  // Color palette (from design template)
  static const Color wood = Color(0xFF8B6F47);
  static const Color woodDark = Color(0xFF7A5C3A);
  static const Color parchment = Color(0xFFEFE8D8);
  static const Color parchmentDeep = Color(0xFFF5F0E6);
  static const Color inkDark = Color(0xFF3D2E1F);
  static const Color inkMid = Color(0xFF5C4A3A);
  static const Color inkLight = Color(0xFF6B5D52);
  static const Color gold = Color(0xFFC9A961);
  static const Color goldLight = Color(0xFFE6B87D);
  static const Color deadlineRed = Color(0xFFA8423F);
  static const Color border = Color(0x666B5237);

  // Gem / project colors
  static const Color gemAmber = Color(0xFFD4923B);
  static const Color gemSapphire = Color(0xFF4A6FA5);
  static const Color gemRuby = Color(0xFFA8423F);
  static const Color gemEmerald = Color(0xFF5B7C5A);
  static const Color gemAmethyst = Color(0xFF7B5EA7);
  static const Color gemOpal = Color(0xFF2E8B8B);
  static const Color gemTopaz = Color(0xFFB8860B);
  static const Color gemOnyx = Color(0xFF5A4A42);

  static const List<Color> gemPalette = [
    gemAmber,
    gemSapphire,
    gemRuby,
    gemEmerald,
    gemAmethyst,
    gemOpal,
    gemTopaz,
    gemOnyx,
  ];

  static ThemeData build() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: gold,
      onPrimary: inkDark,
      primaryContainer: Color(0xFFE8D49A),
      onPrimaryContainer: inkDark,
      secondary: inkMid,
      onSecondary: parchment,
      secondaryContainer: parchmentDeep,
      onSecondaryContainer: inkDark,
      error: deadlineRed,
      onError: parchment,
      surface: parchment,
      onSurface: inkDark,
      surfaceContainerHighest: parchmentDeep,
      outline: Color(0xFF8B7255),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: wood,
      cardColor: parchment,
      cardTheme: const CardThemeData(
        color: parchment,
        shadowColor: Color(0xAA000000),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(fontFamily: 'serif', color: inkDark, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontFamily: 'serif', color: inkMid),
        bodyLarge: TextStyle(color: inkDark, fontSize: 16),
        bodyMedium: TextStyle(color: inkMid, fontSize: 14),
        bodySmall: TextStyle(color: inkLight, fontSize: 13),
        labelLarge: TextStyle(color: inkMid, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 12),
        labelMedium: TextStyle(color: inkMid, fontSize: 12),
        labelSmall: TextStyle(color: inkLight, fontSize: 11),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: parchment,
        foregroundColor: inkDark,
        elevation: 6,
        shadowColor: Color(0x88000000),
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          color: inkDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: parchment,
        indicatorColor: const Color(0x44C9A961),
        elevation: 10,
        shadowColor: const Color(0x88000000),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'serif',
              color: inkDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(color: inkLight, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: inkDark);
          }
          return const IconThemeData(color: inkLight);
        }),
      ),
      dividerColor: const Color(0x335C4A3A),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold, width: 2)),
        fillColor: parchmentDeep,
        filled: true,
        labelStyle: TextStyle(color: inkMid),
        hintStyle: TextStyle(color: inkLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: parchmentDeep,
        selectedColor: gold,
        labelStyle: const TextStyle(color: inkDark, fontWeight: FontWeight.w600, fontSize: 14),
        side: const BorderSide(color: Color(0x4D8B7255)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(gold),
          foregroundColor: WidgetStateProperty.all(inkDark),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(inkMid),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: parchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: parchment,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          color: inkDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: inkDark,
        iconColor: inkMid,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: parchment,
        headerBackgroundColor: wood,
        headerForegroundColor: parchment,
      ),
    );
  }
}
