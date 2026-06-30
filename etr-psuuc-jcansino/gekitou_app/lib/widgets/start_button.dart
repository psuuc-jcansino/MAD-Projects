import 'package:flutter/material.dart';

class PulsingStartButton extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> pulseAnim;

  const PulsingStartButton({
    Key? key,
    required this.onTap,
    required this.pulseAnim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, __) => Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFF7F77DD),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7F77DD,
                ).withOpacity(0.25 * pulseAnim.value),
                blurRadius: 20 * pulseAnim.value,
                spreadRadius: 2 * pulseAnim.value,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 1,
                      height: 80,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 30,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 0.5,
                      height: 80,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.sports_martial_arts_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'START BATTLE',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
