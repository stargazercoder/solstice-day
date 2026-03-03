import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../../features/habits/models/habit_model.dart';

class HabitService {
  final _client = SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  // ========== HABITS ==========

  Future<List<HabitModel>> getActiveHabits() async {
    final data = await _client
        .from('habits')
        .select()
        .eq('user_id', _uid)
        .eq('is_active', true)
        .eq('is_archived', false)
        .order('created_at');
    return data.map((e) => HabitModel.fromJson(e)).toList();
  }

  Future<HabitModel> createHabit(Map<String, dynamic> habitData) async {
    habitData['user_id'] = _uid;
    final data = await _client.from('habits').insert(habitData).select().single();
    return HabitModel.fromJson(data);
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> updates) async {
    await _client.from('habits').update(updates).eq('id', habitId);
  }

  Future<void> deleteHabit(String habitId) async {
    await _client.from('habits').delete().eq('id', habitId);
  }

  Future<void> archiveHabit(String habitId) async {
    await _client.from('habits').update({
      'is_archived': true,
      'is_active': false,
    }).eq('id', habitId);
  }

  // ========== ENTRIES ==========

  Future<List<HabitEntryModel>> getTodayEntries() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final data = await _client
        .from('habit_entries')
        .select()
        .eq('user_id', _uid)
        .eq('entry_date', today);
    return data.map((e) => HabitEntryModel.fromJson(e)).toList();
  }

  Future<List<HabitEntryModel>> getEntriesForDateRange(
    DateTime start, DateTime end,
  ) async {
    final data = await _client
        .from('habit_entries')
        .select()
        .eq('user_id', _uid)
        .gte('entry_date', start.toIso8601String().split('T').first)
        .lte('entry_date', end.toIso8601String().split('T').first);
    return data.map((e) => HabitEntryModel.fromJson(e)).toList();
  }

  Future<HabitEntryModel> upsertEntry({
    required String habitId,
    required int value,
    required int target,
    int? mood,
    String? note,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final isCompleted = value >= target;

    final data = await _client.from('habit_entries').upsert({
      'habit_id': habitId,
      'user_id': _uid,
      'entry_date': today,
      'value': value,
      'target': target,
      'is_completed': isCompleted,
      'mood': mood,
      'note': note,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    }, onConflict: 'habit_id,entry_date').select().single();

    return HabitEntryModel.fromJson(data);
  }

  // ========== PRESETS ==========

  Future<List<PresetHabitModel>> getPresetHabits() async {
    final data = await _client
        .from('preset_habits')
        .select()
        .order('sort_order');
    return data.map((e) => PresetHabitModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _client
        .from('habit_categories')
        .select()
        .order('sort_order');
  }

  // ========== STATS ==========

  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final entries = await getEntriesForDateRange(weekStart, now);

    final completed = entries.where((e) => e.isCompleted).length;
    final total = entries.length;

    return {
      'completed': completed,
      'total': total,
      'rate': total > 0 ? completed / total : 0.0,
    };
  }

  // ========== LEADERBOARD ==========

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return await _client
        .from('leaderboard')
        .select()
        .limit(50);
  }

  Future<List<Map<String, dynamic>>> getHabitLeaderboard(String habitName) async {
    return await _client.rpc('get_habit_leaderboard', params: {
      'habit_name_filter': habitName,
    });
  }
}
