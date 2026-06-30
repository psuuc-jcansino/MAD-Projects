import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing_screen.dart';

void main() {
  runApp(const ThinkyApp());
}

class ThinkyApp extends StatelessWidget {
  const ThinkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thinky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3A5BA0),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.fredoka(
            fontSize: 42,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: GoogleFonts.fredoka(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const LandingScreen(),
    );
  }
}
