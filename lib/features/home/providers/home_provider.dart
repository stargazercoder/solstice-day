import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/habit_service.dart';
import '../../habits/models/habit_model.dart';

final habitServiceProvider = Provider((ref) => HabitService());

final activeHabitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  return ref.read(habitServiceProvider).getActiveHabits();
});

final todayEntriesProvider = FutureProvider<List<HabitEntryModel>>((ref) async {
  return ref.read(habitServiceProvider).getTodayEntries();
});

final weeklyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(habitServiceProvider).getWeeklyStats();
});

final presetHabitsProvider = FutureProvider<List<PresetHabitModel>>((ref) async {
  return ref.read(habitServiceProvider).getPresetHabits();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(habitServiceProvider).getCategories();
});
