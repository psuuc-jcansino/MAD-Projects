import 'package:flutter/material.dart';

import '../constants/shape_type.dart';

class ShapeOptionTile extends StatelessWidget {
  final ShapeType shape;
  final VoidCallback onTap;

  const ShapeOptionTile({super.key, required this.shape, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset('lib/assets/shapes/${shape.name}.png'),
            ),
          ),
        ),
      ),
    );
  }
}
