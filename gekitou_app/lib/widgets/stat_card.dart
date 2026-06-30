import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatCard({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.12), width: 0.5),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
