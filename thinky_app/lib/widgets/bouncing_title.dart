import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BouncingTitle extends StatefulWidget {
  final String text;
  final double fontSize;

  const BouncingTitle({super.key, required this.text, required this.fontSize});

  @override
  State<BouncingTitle> createState() => _BouncingTitleState();
}

class _BouncingTitleState extends State<BouncingTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letters = widget.text.split('');

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(letters.length, (i) {
            final wave = (_controller.value * 2 * pi) + (i * 0.6);
            final offsetY = -10 * sin(wave);

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 4),
                      child: Text(
                        letters[i],
                        style: GoogleFonts.fredoka(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3A5BA0),
                        ),
                      ),
                    ),

                    Text(
                      letters[i],
                      style: GoogleFonts.fredoka(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
