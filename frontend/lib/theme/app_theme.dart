import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Noir Palette
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color primary = Color(0xFFE2B25A); // Gold/Bronze
  static const Color secondary = Color(0xFF8B0000); // Deep Blood Red
  static const Color accent = Color(0xFF4A4A4A);
  static const Color textBody = Color(0xFFE0E0E0);
  static const Color textHeadline = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
      ),
      textTheme: GoogleFonts.metamorphousTextTheme(const TextTheme(
        headlineLarge: TextStyle(
            color: textHeadline,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
        headlineMedium:
            TextStyle(color: textHeadline, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textBody),
        bodyMedium: TextStyle(color: textBody),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.metamorphous(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.metamorphous(fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: accent, width: 0.5)),
      ),
      useMaterial3: true,
    );
  }
}
