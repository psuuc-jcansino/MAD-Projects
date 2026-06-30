import 'package:flutter/material.dart';

class AnimatedStar extends StatefulWidget {
  final bool filled;
  final int delayMs;

  const AnimatedStar({super.key, required this.filled, required this.delayMs});

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = Tween(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacity = Tween(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 54,
          color: Colors.orange,
        ),
      ),
    );
  }
}
