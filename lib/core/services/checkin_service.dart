import 'dart:math';
import 'supabase_service.dart';

class CheckInService {
  final _client = SupabaseService.client;
  final _random = Random();

  Future<Map<String, dynamic>> getRandomPrompt() async {
    final hour = DateTime.now().hour;
    String timeOfDay;
    if (hour < 12) {
      timeOfDay = 'morning';
    } else if (hour < 17) {
      timeOfDay = 'afternoon';
    } else {
      timeOfDay = 'evening';
    }

    final data = await _client
        .from('checkin_prompts')
        .select()
        .or('time_of_day.eq.$timeOfDay,time_of_day.eq.any');

    if (data.isEmpty) return {'prompt_tr': 'Nasil gidiyor?', 'mood_related': false};
    return data[_random.nextInt(data.length)];
  }
}
