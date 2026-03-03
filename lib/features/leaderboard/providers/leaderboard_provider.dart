import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/habit_service.dart';
import '../../home/providers/home_provider.dart';

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(habitServiceProvider).getLeaderboard();
});
