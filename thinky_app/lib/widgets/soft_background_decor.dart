import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SoftBackgroundDecor extends StatelessWidget {
  const SoftBackgroundDecor({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return IgnorePointer(
      child: Stack(
        children: [
          _decorText(
            text: '6',
            size: 190,
            top: -60,
            left: -20,
            angle: -0.18,
            opacity: 0.18,
          ),

          _decorIcon(
            icon: FontAwesomeIcons.palette,
            size: 170,
            top: -20,
            right: -20,
            angle: 0.22,
            opacity: 0.16,
          ),

          _decorIcon(
            icon: FontAwesomeIcons.cubes,
            size: 150,
            top: h * 0.42,
            left: -40,
            angle: -0.25,
            opacity: 0.12,
          ),

          _decorIcon(
            icon: FontAwesomeIcons.bookOpen,
            size: 150,
            top: h * 0.42,
            right: -40,
            angle: 0.25,
            opacity: 0.12,
          ),

          _decorIcon(
            icon: FontAwesomeIcons.font,
            size: 160,
            bottom: -20,
            left: -20,
            angle: -0.18,
            opacity: 0.12,
          ),

          _decorIcon(
            icon: FontAwesomeIcons.shapes,
            size: 170,
            bottom: -20,
            right: -20,
            angle: 0.2,
            opacity: 0.14,
          ),
        ],
      ),
    );
  }

  Widget _decorIcon({
    required IconData icon,
    required double size,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double angle,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Icon(
          icon,
          size: size,
          color: const Color(0xFF3A5BA0).withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _decorText({
    required String text,
    required double size,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double angle,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF3A5BA0).withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}
