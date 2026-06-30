import 'package:challenge_me_etr/screens/about_screen.dart';
import 'package:challenge_me_etr/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Widget _buildIcon(
    IconData icon, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    double angle = 0.0,
    double size = 130,
    double opacity = 0.3,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: FaIcon(
          icon,
          size: size,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required List<Color> gradientColors,
    required Color textColor,
    void Function()? onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.transparent,
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: Image.asset(
                'assets/images/CM.png',
                width: 90,
                height: 90,
                color: Colors.black45.withOpacity(0.6),
              ),
            ),

            Image.asset('assets/images/CM.png', width: 90, height: 90),
          ],
        ),
        const SizedBox(height: 6),

        Stack(
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.bahiana(
                    fontSize: 80,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = Colors.black45,
                  ),
                  children: const [
                    TextSpan(text: 'CHALLENGE'),
                    TextSpan(
                      text: 'ME!',
                      style: TextStyle(color: Color(0xFFFFB74D)),
                    ),
                  ],
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.bahiana(
                  fontSize: 80,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                children: const [
                  TextSpan(
                    text: 'CHALLENGE',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'ME!',
                    style: TextStyle(color: Color(0xFFFFB74D)),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Level up your everyday life!',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4DD0E1), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildIcon(
                FontAwesomeIcons.solidStar,
                top: -40,
                left: -40,
                angle: -0.3,
              ),
              _buildIcon(
                FontAwesomeIcons.paintbrush,
                top: -40,
                right: -40,
                angle: 0.3,
              ),
              _buildIcon(
                FontAwesomeIcons.heart,
                bottom: -40,
                left: -40,
                angle: 0.2,
              ),
              _buildIcon(FontAwesomeIcons.gem, bottom: -40, right: -0.2),
              _buildIcon(
                FontAwesomeIcons.lightbulb,
                top: 300,
                left: -20,
                angle: -0.1,
              ),
              _buildIcon(
                FontAwesomeIcons.brain,
                top: 300,
                right: -20,
                angle: 0.1,
              ),

              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(child: _buildTitleSection()),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildButton(
                        text: 'Start Challenge',
                        gradientColors: const [
                          Color(0xFF6DE0EB),
                          Color(0xFF4DD0E1),
                        ],
                        textColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildButton(
                        text: 'About Game',
                        gradientColors: const [
                          Color(0xFFFFD17A),
                          Color(0xFFFFB74D),
                        ],
                        textColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutGameScreen(),
                            ),
                          );
                        },
                      ),
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
}
