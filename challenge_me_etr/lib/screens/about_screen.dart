import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutGameScreen extends StatelessWidget {
  const AboutGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 130;
    const double iconOpacity = 0.25;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4DD0E1), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildFloatingIcon(
                FontAwesomeIcons.solidStar,
                -60,
                -40,
                -0.25,
                iconSize,
                iconOpacity,
                top: true,
                left: true,
              ),
              _buildFloatingIcon(
                FontAwesomeIcons.paintbrush,
                -50,
                -50,
                0.25,
                iconSize,
                iconOpacity,
                top: true,
                right: true,
              ),
              _buildFloatingIcon(
                FontAwesomeIcons.heart,
                -40,
                -60,
                0.2,
                iconSize,
                iconOpacity,
                bottom: true,
                left: true,
              ),
              _buildFloatingIcon(
                FontAwesomeIcons.gem,
                -50,
                -50,
                -0.2,
                iconSize,
                iconOpacity,
                bottom: true,
                right: true,
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 80,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            for (int i = 3; i >= 1; i--)
                              Positioned(
                                left: i.toDouble(),
                                top: i.toDouble(),
                                child: FaIcon(
                                  FontAwesomeIcons.lightbulb,
                                  size: 80,
                                  color: Colors.black.withOpacity(0.1 * i),
                                ),
                              ),
                            const FaIcon(
                              FontAwesomeIcons.lightbulb,
                              size: 80,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      _buildTitle(),
                      const SizedBox(height: 30),
                      Text(
                        'ChallengeMe! lets you step out of your comfort zone with small, fun daily challenges. '
                        'Each day, try a new task to boost creativity, practice mindfulness, or connect with others. '
                        'Track your progress, see your completed challenges, and enjoy the thrill of surprising yourself '
                        'with a random challenge each day. Make self-improvement playful, rewarding, and exciting!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 200,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD17A), Color(0xFFFFB74D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: Text(
                            'GOT IT!',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(
    IconData icon,
    double xOffset,
    double yOffset,
    double rotation,
    double size,
    double opacity, {
    bool top = false,
    bool bottom = false,
    bool left = false,
    bool right = false,
  }) {
    return Positioned(
      top: top ? yOffset : null,
      bottom: bottom ? yOffset : null,
      left: left ? xOffset : null,
      right: right ? xOffset : null,
      child: Transform.rotate(
        angle: rotation,
        child: FaIcon(
          icon,
          size: size,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Text(
            'ABOUT GAME',
            style: GoogleFonts.bahiana(
              fontSize: 62,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black45,
            ),
          ),
        ),
        Text(
          'ABOUT GAME',
          style: GoogleFonts.bahiana(
            fontSize: 62,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(3, 3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
