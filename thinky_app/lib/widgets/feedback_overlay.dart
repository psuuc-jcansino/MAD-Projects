import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.onDismiss,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();

    /// Auto dismiss
    Timer(const Duration(milliseconds: 1200), () {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: widget.isCorrect
                    ? const Color(0xFF6FCF97)
                    : const Color(0xFFFF7675),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 96,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isCorrect ? 'Great job!' : 'Try again!',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
