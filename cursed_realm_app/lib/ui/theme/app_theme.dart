import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Color Palette ─────────────────────────────────────────────────────────

  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color surfaceVariant = Color(0xFF1C1C26);
  static const Color border = Color(0xFF2A2A3A);

  static const Color primary = Color(0xFFB22222); // dark crimson
  static const Color primaryLight = Color(0xFFCC3333);
  static const Color accent = Color(0xFF7C3AED); // deep violet

  static const Color gold = Color(0xFFD4A017);
  static const Color hpRed = Color(0xFFE53935);
  static const Color mpBlue = Color(0xFF1E88E5);
  static const Color xpGreen = Color(0xFF43A047);

  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF8A8AA0);
  static const Color textMuted = Color(0xFF4A4A5A);

  // Rarity colors
  static const Color rarityCommon = Color(0xFFAAAAAA);
  static const Color rarityUncommon = Color(0xFF4CAF50);
  static const Color rarityRare = Color(0xFF2196F3);
  static const Color rarityEpic = Color(0xFF9C27B0);
  static const Color rarityLegendary = Color(0xFFFF9800);

  // ── Theme ─────────────────────────────────────────────────────────────────

  static ThemeData get darkGothic {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: hpRed,
      ),
      textTheme: GoogleFonts.cinzelTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(
              color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
              color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 12),
          labelLarge: TextStyle(
              color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: primaryLight, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      dividerColor: border,
      cardColor: surfaceVariant,
    );
  }
}
