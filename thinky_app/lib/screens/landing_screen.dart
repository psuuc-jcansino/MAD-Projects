import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/bouncing_title.dart';
import '../widgets/soft_background_decor.dart';
import 'who_is_playing_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
          ),
        ),
        child: Stack(
          children: [
            const SoftBackgroundDecor(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 96),

                    const BouncingTitle(text: 'Thinky', fontSize: 80),

                    const SizedBox(height: 8),

                    Text(
                      'Learn • Play • Grow',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: 220,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WhoIsPlayingScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A5BA0),
                          elevation: 8,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                        ),
                        child: Text(
                          'PLAY!',
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
