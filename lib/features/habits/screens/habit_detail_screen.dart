import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/color_constants.dart';
import '../../home/providers/home_provider.dart';
import '../models/habit_model.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final entriesAsync = ref.watch(todayEntriesProvider);

    return habitsAsync.when(
      data: (habits) {
        final habit = habits.where((h) => h.id == widget.habitId).firstOrNull;
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Alışkanlık bulunamadı')),
          );
        }

        Color habitColor;
        try {
          habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));
        } catch (_) {
          habitColor = AppColors.primary;
        }

        return entriesAsync.when(
          data: (entries) {
            final entry = entries.where((e) => e.habitId == habit.id).firstOrNull;
            final progress = entry != null && habit.targetCount > 0
                ? (entry.value / habit.targetCount).clamp(0.0, 1.0)
                : 0.0;

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [habitColor, habitColor.withOpacity(0.7)],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              CircularPercentIndicator(
                                radius: 50,
                                lineWidth: 8,
                                percent: progress,
                                center: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                progressColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                habit.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Düzenle'),
                          ),
                          const PopupMenuItem(
                            value: 'archive',
                            child: Text('Arşivle'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Sil', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onSelected: (val) => _handleAction(val, habit),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats cards
                          Row(
                            children: [
                              _buildStatCard('Mevcut Seri', '${habit.currentStreak}', '🔥', habitColor),
                              const SizedBox(width: 12),
                              _buildStatCard('En İyi Seri', '${habit.bestStreak}', '🏆', habitColor),
                              const SizedBox(width: 12),
                              _buildStatCard('Toplam', '${habit.totalCompletions}', '✅', habitColor),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Today's progress
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: habitColor.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bugünkü İlerleme',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: habitColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton.filled(
                                      onPressed: () => _updateValue(habit, entry, -1),
                                      icon: const Icon(Icons.remove),
                                      style: IconButton.styleFrom(
                                        backgroundColor: habitColor.withOpacity(0.15),
                                        foregroundColor: habitColor,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      '${entry?.value ?? 0} / ${habit.targetCount}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: habitColor,
                                      ),
                                    ),
                                    if (habit.unit != null) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        habit.unit!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: habitColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 20),
                                    IconButton.filled(
                                      onPressed: () => _updateValue(habit, entry, 1),
                                      icon: const Icon(Icons.add),
                                      style: IconButton.styleFrom(
                                        backgroundColor: habitColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Info section
                          if (habit.description != null) ...[
                            Text(
                              'Açıklama',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(habit.description!),
                            const SizedBox(height: 16),
                          ],

                          // Meta info
                          _buildInfoRow('Sıklık', _frequencyText(habit)),
                          _buildInfoRow('Başlangıç', '${habit.startDate.day}.${habit.startDate.month}.${habit.startDate.year}'),
                          if (habit.endDate != null)
                            _buildInfoRow('Bitiş', '${habit.endDate!.day}.${habit.endDate!.month}.${habit.endDate!.year}'),
                          _buildInfoRow('Tamamlama Oranı', '${(habit.completionRate * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }

  Widget _buildStatCard(String label, String value, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _frequencyText(HabitModel habit) {
    switch (habit.frequency) {
      case 'daily': return 'Her Gün';
      case 'weekly': return 'Haftalık';
      case 'custom':
        final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        return habit.customDays.map((d) => days[d]).join(', ');
      default: return habit.frequency;
    }
  }

  Future<void> _updateValue(HabitModel habit, HabitEntryModel? entry, int delta) async {
    final current = entry?.value ?? 0;
    final newVal = (current + delta).clamp(0, habit.targetCount * 2);

    try {
      await ref.read(habitServiceProvider).upsertEntry(
        habitId: habit.id,
        value: newVal,
        target: habit.targetCount,
      );
      ref.invalidate(todayEntriesProvider);
      ref.invalidate(activeHabitsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _handleAction(String action, HabitModel habit) async {
    final service = ref.read(habitServiceProvider);
    switch (action) {
      case 'archive':
        await service.archiveHabit(habit.id);
        ref.invalidate(activeHabitsProvider);
        if (mounted) context.pop();
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Alışkanlığı Sil'),
            content: const Text('Bu alışkanlığı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await service.deleteHabit(habit.id);
          ref.invalidate(activeHabitsProvider);
          if (mounted) context.pop();
        }
        break;
    }
  }
}
