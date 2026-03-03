import 'package:flutter/material.dart';

class IconUtils {
  static final Map<String, IconData> iconMap = {
    'water_drop': Icons.water_drop,
    'fitness_center': Icons.fitness_center,
    'menu_book': Icons.menu_book,
    'self_improvement': Icons.self_improvement,
    'alarm': Icons.alarm,
    'edit_note': Icons.edit_note,
    'directions_walk': Icons.directions_walk,
    'restaurant': Icons.restaurant,
    'translate': Icons.translate,
    'check_circle': Icons.check_circle,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'spa': Icons.spa,
    'brush': Icons.brush,
    'phone_disabled': Icons.phone_disabled,
    'medication': Icons.medication,
    'savings': Icons.savings,
    'school': Icons.school,
    'people': Icons.people,
    'palette': Icons.palette,
    'trending_up': Icons.trending_up,
    'face_retouching_natural': Icons.face_retouching_natural,
    'family_restroom': Icons.family_restroom,
  };

  static IconData getIcon(String name) {
    return iconMap[name] ?? Icons.check_circle;
  }
}
