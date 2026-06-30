import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryModel {
  final int? id;
  final String title;
  final Color color;
  final IconData icon;

  CategoryModel({
    this.id,
    required this.title,
    required this.color,
    required this.icon,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      title: map['title'] ?? 'Unknown',
      color: Color(map['color'] ?? 0xFF000000),
      icon: IconData(map['icon'] ?? 0xf0c0, fontFamily: 'FontAwesomeSolid'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      id: 1,
      title: 'SOCIAL',
      color: const Color(0xFF81D4FA),
      icon: FontAwesomeIcons.peopleGroup,
    ),
    CategoryModel(
      id: 2,
      title: 'CREATIVE',
      color: const Color(0xFFFFCC80),
      icon: FontAwesomeIcons.paintBrush,
    ),
    CategoryModel(
      id: 3,
      title: 'PHYSICAL',
      color: const Color(0xFFA5D6A7),
      icon: FontAwesomeIcons.dumbbell,
    ),
    CategoryModel(
      id: 4,
      title: 'MINDFULNESS',
      color: const Color(0xFFE6EE9C),
      icon: FontAwesomeIcons.brain,
    ),
    CategoryModel(
      id: 5,
      title: 'LEARNING',
      color: const Color(0xFFCE93D8),
      icon: FontAwesomeIcons.bookOpen,
    ),
    CategoryModel(
      id: 6,
      title: 'FUN',
      color: const Color(0xFFFF90A0),
      icon: FontAwesomeIcons.faceLaughBeam,
    ),
  ];
}
