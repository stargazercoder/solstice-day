import 'package:flutter/material.dart';

class AppColors {
  // Primary — Turuncu Enerji
  static const Color primary = Color(0xFFFF6B2C);
  static const Color primaryLight = Color(0xFFFF9A6C);
  static const Color primaryDark = Color(0xFFE05A1B);

  // Accent — Sarı Kutlama
  static const Color accent = Color(0xFFFFD93D);
  static const Color accentLight = Color(0xFFFFE88D);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral — Sıcak tonlar
  static const Color background = Color(0xFFFFF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF0E6);
  static const Color textPrimary = Color(0xFF2D1B0E);
  static const Color textSecondary = Color(0xFF7A6B5D);
  static const Color textHint = Color(0xFFB0A090);
  static const Color divider = Color(0xFFEDE0D4);

  // Dark theme — Sıcak koyu
  static const Color darkBackground = Color(0xFF1A1209);
  static const Color darkSurface = Color(0xFF2A1F14);
  static const Color darkSurfaceVariant = Color(0xFF3D2E1F);
  static const Color darkTextPrimary = Color(0xFFFFF8F3);

  // Streak ateşi
  static const Color streakFire = Color(0xFFFF4500);
  static const Color streakGold = Color(0xFFFFD700);

  // Fihrist / Not Defteri bölüm renkleri
  static const Color sectionDiary = Color(0xFFFF6B2C);      // Günlük
  static const Color sectionWorkout = Color(0xFF4CAF50);     // Spor
  static const Color sectionDiet = Color(0xFF8BC34A);        // Diyet
  static const Color sectionShopping = Color(0xFF2196F3);    // Alışveriş
  static const Color sectionReading = Color(0xFF9C27B0);     // Okuma
  static const Color sectionGoals = Color(0xFFFF9800);       // Hedefler
  static const Color sectionNotes = Color(0xFF607D8B);       // Genel Not

  // Hatırlatma türleri
  static const Color reminderMeeting = Color(0xFF2196F3);    // Toplantı
  static const Color reminderDoctor = Color(0xFFF44336);     // Doktor
  static const Color reminderDate = Color(0xFFE91E63);       // Date
  static const Color reminderMedicine = Color(0xFF4CAF50);   // İlaç
  static const Color reminderWater = Color(0xFF03A9F4);      // Su
  static const Color reminderSleep = Color(0xFF7C4DFF);      // Uyku

  // Habit colors
  static const List<Color> habitColors = [
    Color(0xFFFF6B2C), Color(0xFFFF6B6B), Color(0xFF4CAF50),
    Color(0xFFFF9800), Color(0xFF2196F3), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFF00BCD4), Color(0xFF8BC34A),
    Color(0xFFFF5722), Color(0xFF607D8B), Color(0xFFFFC107),
  ];

  static const List<List<Color>> gradients = [
    [Color(0xFFFF6B2C), Color(0xFFFF9A6C)],   // Primary turuncu
    [Color(0xFFFFD93D), Color(0xFFFF6B2C)],   // Kutlama (sarı>turuncu)
    [Color(0xFFFF4500), Color(0xFFFFD93D)],   // Streak ateşi
    [Color(0xFF4CAF50), Color(0xFF81C784)],   // Yeşil
    [Color(0xFF2196F3), Color(0xFF64B5F6)],   // Mavi
    [Color(0xFFE91E63), Color(0xFFF48FB1)],   // Pembe
  ];
}
