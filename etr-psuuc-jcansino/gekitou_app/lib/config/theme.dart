import 'package:flutter/material.dart';

class GekitouTheme {
  static const Color primaryColor = Color(0xFF6B5FFF);
  static const Color primaryDark = Color(0xFF5147CC);
  static const Color primaryLight = Color(0xFF8B7FFF);

  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);

  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color surfaceColor = Color(0xFF16213E);
  static const Color cardColor = Color(0xFF0F3460);

  static const Color textPrimaryColor = Color(0xFFEAEAEA);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color textHintColor = Color(0xFF808080);

  static const Color errorColor = Color(0xFFEF5350);
  static const Color dividerColor = Color(0xFF2A2A3E);

  static const Color playerColor = Color(0xFF4CAF50);
  static const Color enemyColor = Color(0xFFEF5350);
  static const Color healthColor = Color(0xFF4CAF50);
  static const Color damageColor = Color(0xFFEF5350);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimaryColor, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimaryColor, fontSize: 14),
        bodySmall: TextStyle(color: textSecondaryColor, fontSize: 12),
        labelLarge: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(color: textHintColor, fontSize: 10),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textHintColor),
        errorStyle: const TextStyle(color: errorColor),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }

  static ColorScheme get colorScheme {
    return ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
      background: backgroundColor,
      onBackground: textPrimaryColor,
      error: errorColor,
      onError: Colors.white,
    );
  }
}
