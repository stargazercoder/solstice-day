import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // Accent
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9B9B);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F8);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252540);
  static const Color darkTextPrimary = Color(0xFFF8F9FE);

  // Habit colors
  static const List<Color> habitColors = [
    Color(0xFF6C63FF), Color(0xFFFF6B6B), Color(0xFF4CAF50),
    Color(0xFFFF9800), Color(0xFF2196F3), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFF00BCD4), Color(0xFF8BC34A),
    Color(0xFFFF5722), Color(0xFF607D8B), Color(0xFFFFC107),
  ];

  static const List<List<Color>> gradients = [
    [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    [Color(0xFFFF6B6B), Color(0xFFFFAB91)],
    [Color(0xFF4CAF50), Color(0xFF81C784)],
    [Color(0xFF2196F3), Color(0xFF64B5F6)],
    [Color(0xFFE91E63), Color(0xFFF48FB1)],
    [Color(0xFF00BCD4), Color(0xFF80DEEA)],
  ];
}
