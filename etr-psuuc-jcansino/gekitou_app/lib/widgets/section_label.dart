import 'package:flutter/material.dart';

class AnimeSection extends StatelessWidget {
  final String label;
  const AnimeSection({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: const Color(0xFF7F77DD)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 0.5, color: Colors.white.withOpacity(0.07)),
        ),
      ],
    );
  }
}
