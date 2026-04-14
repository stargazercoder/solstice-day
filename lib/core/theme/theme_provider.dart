import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanılabilir accent renkler
class AccentColor {
  final String name;
  final Color color;
  const AccentColor(this.name, this.color);
}

const List<AccentColor> accentColors = [
  AccentColor('Turuncu', Color(0xFFFF6B2C)),
  AccentColor('Mercan', Color(0xFFFF6B6B)),
  AccentColor('Nane', Color(0xFF4CAF50)),
  AccentColor('Lime', Color(0xFF8BC34A)),
  AccentColor('Mavi', Color(0xFF2196F3)),
  AccentColor('Mor', Color(0xFF9C27B0)),
  AccentColor('Pembe', Color(0xFFE91E63)),
  AccentColor('Cyan', Color(0xFF00BCD4)),
  AccentColor('Amber', Color(0xFFFF9800)),
  AccentColor('Kırmızı', Color(0xFFF44336)),
];

class ThemeSettings {
  final ThemeMode themeMode;
  final int accentColorIndex;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.accentColorIndex = 0,
  });

  Color get accentColor => accentColors[accentColorIndex].color;

  ThemeSettings copyWith({ThemeMode? themeMode, int? accentColorIndex}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('themeMode') ?? 0;
    final colorIndex = prefs.getInt('accentColorIndex') ?? 0;
    state = ThemeSettings(
      themeMode: ThemeMode.values[modeIndex.clamp(0, 2)],
      accentColorIndex: colorIndex.clamp(0, accentColors.length - 1),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setAccentColor(int index) async {
    state = state.copyWith(accentColorIndex: index.clamp(0, accentColors.length - 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColorIndex', index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});
