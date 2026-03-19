import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color scaffoldBackground = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF141414);
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D48B);
  static const Color goldDark = Color(0xFFB8960C);
  static const Color priceGreen = Color(0xFF00E676);
  static const Color priceRed = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color dividerColor = Color(0xFF2A2A2A);
  static const Color shimmerBase = Color(0xFF1E1E1E);
  static const Color shimmerHighlight = Color(0xFF2E2E2E);
  static const Color chartLine = Color(0xFFD4AF37);
  static const Color chartFill = Color(0x33D4AF37);
  static const Color chartGrid = Color(0xFF1F1F1F);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: surfaceColor,
        error: priceRed,
        onPrimary: scaffoldBackground,
        onSecondary: scaffoldBackground,
        onSurface: textPrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      displayLarge: GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -1.0,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 2.0,
      ),
    );
  }
}
