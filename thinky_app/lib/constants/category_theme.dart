import 'package:flutter/material.dart';
import 'category.dart';

class CategoryTheme {
  final List<Color> backgroundGradient;
  final Color accentColor;

  const CategoryTheme({
    required this.backgroundGradient,
    required this.accentColor,
  });
}

const Map<CategoryType, CategoryTheme> categoryThemes = {
  CategoryType.numbers: CategoryTheme(
    backgroundGradient: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
    accentColor: Color(0xFF3A5BA0),
  ),

  CategoryType.letters: CategoryTheme(
    backgroundGradient: [Color(0xFFAF7AC5), Color(0xFFF3E5F5)],
    accentColor: Color(0xFF6C3483),
  ),

  CategoryType.shapes: CategoryTheme(
    backgroundGradient: [Color(0xFF58D68D), Color(0xFFE9F7EF)],
    accentColor: Color(0xFF1E8449),
  ),

  CategoryType.colors: CategoryTheme(
    backgroundGradient: [Color(0xFFF5B041), Color(0xFFFFF3E0)],
    accentColor: Color(0xFFB9770E),
  ),
};
