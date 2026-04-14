import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color_constants.dart';

/// Vücut ölçümü
class BodyMeasurement {
  final DateTime date;
  final double weight;
  final double? waist;
  final double? chest;
  final double? biceps;

  BodyMeasurement({
    required this.date,
    required this.weight,
    this.waist,
    this.chest,
    this.biceps,
  });
}

final bodyMeasurementsProvider =
    StateNotifierProvider<BodyMeasurementNotifier, List<BodyMeasurement>>((ref) {
  return BodyMeasurementNotifier();
});

class BodyMeasurementNotifier extends StateNotifier<List<BodyMeasurement>> {
  BodyMeasurementNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('body_measurements') ?? [];
    final entries = <BodyMeasurement>[];
    for (final item in data) {
      final parts = item.split('|');
      if (parts.length >= 2) {
        entries.add(BodyMeasurement(
          date: DateTime.parse(parts[0]),
          weight: double.parse(parts[1]),
          waist: parts.length > 2 && parts[2].isNotEmpty ? double.tryParse(parts[2]) : null,
          chest: parts.length > 3 && parts[3].isNotEmpty ? double.tryParse(parts[3]) : null,
          biceps: parts.length > 4 && parts[4].isNotEmpty ? double.tryParse(parts[4]) : null,
        ));
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    state = entries;
  }

  Future<void> addMeasurement(BodyMeasurement m) async {
    state = [m, ...state];
    if (state.length > 60) state = state.sublist(0, 60);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((m) {
      return '${m.date.toIso8601String()}|${m.weight}|${m.waist ?? ''}|${m.chest ?? ''}|${m.biceps ?? ''}';
    }).toList();
    await prefs.setStringList('body_measurements', data);
  }
}

/// Haftalık antrenman programı
class WorkoutEntry {
  final String day;
  final String exercise;
  final String details;

  WorkoutEntry({required this.day, required this.exercise, this.details = ''});
}

final workoutProgramProvider =
    StateNotifierProvider<WorkoutProgramNotifier, List<WorkoutEntry>>((ref) {
  return WorkoutProgramNotifier();
});

class WorkoutProgramNotifier extends StateNotifier<List<WorkoutEntry>> {
  WorkoutProgramNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('workout_program') ?? [];
    final entries = data.map((item) {
      final parts = item.split('||');
      return WorkoutEntry(
        day: parts[0],
        exercise: parts.length > 1 ? parts[1] : '',
        details: parts.length > 2 ? parts[2] : '',
      );
    }).toList();
    state = entries;
  }

  Future<void> addEntry(WorkoutEntry entry) async {
    state = [...state, entry];
    await _save();
  }

  Future<void> removeEntry(int index) async {
    final list = List<WorkoutEntry>.from(state);
    list.removeAt(index);
    state = list;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((e) => '${e.day}||${e.exercise}||${e.details}').toList();
    await prefs.setStringList('workout_program', data);
  }
}

class FitnessSection extends ConsumerWidget {
  const FitnessSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(bodyMeasurementsProvider);
    final workouts = ref.watch(workoutProgramProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vücut Ölçümleri
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📏 Vücut Ölçümleri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton.icon(
              onPressed: () => _showAddMeasurementDialog(context, ref),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ekle', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        if (measurements.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Henüz ölçüm eklenmedi\nKilo, bel, göğüs, biceps takibi yapın',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          )
        else
          ...measurements.take(5).map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Text(
                      '${m.date.day}.${m.date.month}',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    _buildMeasurementChip('⚖️', '${m.weight}kg'),
                    if (m.waist != null) _buildMeasurementChip('📐', '${m.waist}cm'),
                    if (m.chest != null) _buildMeasurementChip('📏', '${m.chest}cm'),
                    if (m.biceps != null) _buildMeasurementChip('💪', '${m.biceps}cm'),
                  ],
                ),
              )),

        const SizedBox(height: 20),

        // Antrenman Programı
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🗓️ Antrenman Programı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            TextButton.icon(
              onPressed: () => _showAddWorkoutDialog(context, ref),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ekle', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        if (workouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Haftalık antrenman programınızı oluşturun',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          )
        else
          ...workouts.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(e.value.day,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.exercise, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (e.value.details.isNotEmpty)
                            Text(e.value.details,
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: AppColors.textHint),
                      onPressed: () => ref.read(workoutProgramProvider.notifier).removeEntry(e.key),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildMeasurementChip(String emoji, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$emoji $value', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddMeasurementDialog(BuildContext context, WidgetRef ref) {
    final weightCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final bicepsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📏 Ölçüm Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kilo (kg) *')),
              const SizedBox(height: 8),
              TextField(controller: waistCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bel (cm)')),
              const SizedBox(height: 8),
              TextField(controller: chestCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Göğüs (cm)')),
              const SizedBox(height: 8),
              TextField(controller: bicepsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Biceps (cm)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightCtrl.text);
              if (weight == null) return;
              ref.read(bodyMeasurementsProvider.notifier).addMeasurement(BodyMeasurement(
                date: DateTime.now(),
                weight: weight,
                waist: double.tryParse(waistCtrl.text),
                chest: double.tryParse(chestCtrl.text),
                biceps: double.tryParse(bicepsCtrl.text),
              ));
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context, WidgetRef ref) {
    final exerciseCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String day = 'Pazartesi';
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('🏋️ Antrenman Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: day,
                decoration: const InputDecoration(labelText: 'Gün'),
                items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => day = val ?? day),
              ),
              const SizedBox(height: 8),
              TextField(controller: exerciseCtrl, decoration: const InputDecoration(labelText: 'Egzersiz *', hintText: 'Koşu, Ağırlık, Yüzme...')),
              const SizedBox(height: 8),
              TextField(controller: detailsCtrl, decoration: const InputDecoration(labelText: 'Detaylar', hintText: '3x12 bench press, 20dk koşu...')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                if (exerciseCtrl.text.trim().isEmpty) return;
                ref.read(workoutProgramProvider.notifier).addEntry(WorkoutEntry(
                  day: day,
                  exercise: exerciseCtrl.text.trim(),
                  details: detailsCtrl.text.trim(),
                ));
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
