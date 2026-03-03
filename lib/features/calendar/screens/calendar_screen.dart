import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/services/habit_service.dart';
import '../../home/providers/home_provider.dart';
import '../../habits/models/habit_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<HabitEntryModel>> _entriesByDate = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(habitServiceProvider);
      final start = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);
      final entries = await service.getEntriesForDateRange(start, end);

      final map = <DateTime, List<HabitEntryModel>>{};
      for (final entry in entries) {
        final dateKey = DateTime(entry.entryDate.year, entry.entryDate.month, entry.entryDate.day);
        map.putIfAbsent(dateKey, () => []).add(entry);
      }
      setState(() {
        _entriesByDate = map;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<HabitEntryModel> _getEntriesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _entriesByDate[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Takvim')),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(2024, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEntries();
              },
              eventLoader: _getEntriesForDay,
              locale: 'tr_TR',
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected day entries
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Bir gün seçin'))
                : _buildDayEntries(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayEntries() {
    final entries = _getEntriesForDay(_selectedDay!);
    final habitsAsync = ref.watch(activeHabitsProvider);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'Bu gün için kayıt yok',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return habitsAsync.when(
      data: (habits) {
        final habitMap = {for (var h in habits) h.id: h};

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final habit = habitMap[entry.habitId];
            if (habit == null) return const SizedBox.shrink();

            Color habitColor;
            try {
              habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));
            } catch (_) {
              habitColor = AppColors.primary;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: entry.isCompleted
                    ? habitColor.withOpacity(0.08)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: entry.isCompleted
                      ? habitColor.withOpacity(0.2)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    entry.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: entry.isCompleted ? habitColor : AppColors.textHint,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '${entry.value}/${entry.target} ${habit.unit ?? ''}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (entry.mood != null)
                    Text(
                      ['😞', '😕', '😐', '🙂', '😄'][entry.mood! - 1],
                      style: const TextStyle(fontSize: 20),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }
}
