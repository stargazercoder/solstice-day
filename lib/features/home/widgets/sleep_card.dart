import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color_constants.dart';

/// Uyku verisi
class SleepEntry {
  final DateTime date;
  final double hours;
  final int quality; // 1-5

  SleepEntry({required this.date, required this.hours, required this.quality});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'hours': hours,
        'quality': quality,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        date: DateTime.parse(json['date']),
        hours: (json['hours'] as num).toDouble(),
        quality: json['quality'] as int,
      );
}

/// SharedPreferences tabanlı uyku provider
final sleepHistoryProvider = StateNotifierProvider<SleepHistoryNotifier, List<SleepEntry>>((ref) {
  return SleepHistoryNotifier();
});

class SleepHistoryNotifier extends StateNotifier<List<SleepEntry>> {
  SleepHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('sleep_history') ?? [];
    final entries = <SleepEntry>[];
    for (final item in data) {
      try {
        final parts = item.split('|');
        entries.add(SleepEntry(
          date: DateTime.parse(parts[0]),
          hours: double.parse(parts[1]),
          quality: int.parse(parts[2]),
        ));
      } catch (_) {}
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    state = entries;
  }

  Future<void> addEntry(double hours, int quality) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Aynı gün varsa güncelle
    final updated = state.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return d != today;
    }).toList();
    updated.insert(0, SleepEntry(date: today, hours: hours, quality: quality));
    // Son 30 günü tut
    if (updated.length > 30) updated.removeRange(30, updated.length);
    state = updated;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((e) => '${e.date.toIso8601String()}|${e.hours}|${e.quality}').toList();
    await prefs.setStringList('sleep_history', data);
  }
}

class SleepCard extends ConsumerStatefulWidget {
  const SleepCard({super.key});

  @override
  ConsumerState<SleepCard> createState() => _SleepCardState();
}

class _SleepCardState extends ConsumerState<SleepCard> {
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(sleepHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayEntry = _getTodayEntry(history);
    final last7 = history.take(7).toList().reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('😴', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text('Uyku Takibi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              if (todayEntry == null)
                TextButton.icon(
                  onPressed: () => _showSleepDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ekle', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _showSleepDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${todayEntry.hours.toStringAsFixed(1)} saat ${'⭐' * todayEntry.quality}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.info),
                    ),
                  ),
                ),
            ],
          ),
          // 7 günlük mini bar chart
          if (last7.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last7.map((e) {
                  final barHeight = (e.hours / 12 * 40).clamp(4.0, 40.0);
                  final dayName = _shortDayName(e.date.weekday);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        e.hours.toStringAsFixed(0),
                        style: TextStyle(fontSize: 9, color: AppColors.textHint),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 24,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: _sleepColor(e.hours),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dayName, style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Uyku veriniz henüz yok. Bugünün uyku süresini ekleyin!',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  SleepEntry? _getTodayEntry(List<SleepEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final e in history) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d == today) return e;
    }
    return null;
  }

  Color _sleepColor(double hours) {
    if (hours >= 7) return AppColors.success;
    if (hours >= 5) return AppColors.warning;
    return AppColors.error;
  }

  String _shortDayName(int weekday) {
    const days = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
    return days[weekday - 1];
  }

  void _showSleepDialog() {
    double hours = 7.0;
    int quality = 3;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('😴 Uyku Kaydı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Saat slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uyku Süresi'),
                  Text('${hours.toStringAsFixed(1)} saat',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              Slider(
                value: hours,
                min: 0,
                max: 14,
                divisions: 28,
                onChanged: (val) => setState(() => hours = val),
              ),
              const SizedBox(height: 12),
              // Kalite
              const Text('Uyku Kalitesi'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => quality = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < quality ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(sleepHistoryProvider.notifier).addEntry(hours, quality);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
