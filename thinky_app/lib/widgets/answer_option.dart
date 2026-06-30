import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerOption extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const AnswerOption({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _press = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, __) {
          final pressOffset = 4 * _press.value;
          final shadowOffset = (5 - pressOffset).clamp(2.0, 5.0);

          return Transform.translate(
            offset: Offset(0, pressOffset),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: widget.compact ? 16 : 22,
                horizontal: 12,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.compact ? 18 : 24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 0,
                    offset: Offset(0, shadowOffset),
                  ),
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: widget.compact ? 18 : 26,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A5BA0),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
