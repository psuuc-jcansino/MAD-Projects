import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/color_type.dart';

class ColorOptionTile extends StatelessWidget {
  final ColorType color;
  final VoidCallback onTap;

  const ColorOptionTile({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.value,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            color.name.toUpperCase(),
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
