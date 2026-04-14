import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../providers/home_provider.dart';
import '../../habits/models/habit_model.dart';
import '../widgets/habit_card.dart';
import '../widgets/checkin_dialog.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/sleep_card.dart';
import '../widgets/todo_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _random = Random();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 17) return 'İyi Günler';
    return 'İyi Akşamlar';
  }

  String get _quote =>
      AppConstants.quotes[_random.nextInt(AppConstants.quotes.length)];

  String get _dailyQuestion => AppConstants.todayQuestion;

  @override
  void initState() {
    super.initState();
    // Show check-in dialog periodically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowCheckin();
    });
  }

  void _maybeShowCheckin() {
    // Show check-in prompt randomly (30% chance on each visit)
    if (_random.nextDouble() < 0.3) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const CheckInDialog(),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final entriesAsync = ref.watch(todayEntriesProvider);
    final statsAsync = ref.watch(weeklyStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeHabitsProvider);
          ref.invalidate(todayEntriesProvider);
          ref.invalidate(weeklyStatsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_greeting! 👋',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '💭 $_dailyQuestion',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        // Notification & Friends
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.push('/friends'),
                              icon: const Icon(Icons.people_outline, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats row
                    statsAsync.when(
                      data: (stats) => _buildStatsRow(stats),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Weekly Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: statsAsync.when(
                  data: (stats) => const WeeklyChart(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Uyku Takibi Kartı
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SleepCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bugünkü Alışkanlıklar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    habitsAsync.when(
                      data: (habits) => Text(
                        '${habits.length} aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Habits list
            habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  );
                }

                return entriesAsync.when(
                  data: (entries) {
                    final entryMap = <String, HabitEntryModel>{};
                    for (final e in entries) {
                      entryMap[e.habitId] = e;
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habit = habits[index];
                            final entry = entryMap[habit.id];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                habit: habit,
                                entry: entry,
                                onTap: () => context.push('/habit/${habit.id}'),
                                onComplete: () => _toggleHabit(habit, entry),
                              ),
                            );
                          },
                          childCount: habits.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Center(child: Text('Hata oluştu')),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Hata: $e')),
              ),
            ),

            // Görevler
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TodoCard(),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final completed = stats['completed'] as int;
    final total = stats['total'] as int;
    final rate = stats['rate'] as double;

    return Row(
      children: [
        // Completion circle
        CircularPercentIndicator(
          radius: 36,
          lineWidth: 5,
          percent: rate.clamp(0.0, 1.0),
          center: Text(
            '${(rate * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          progressColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu Hafta',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completed / $total tamamlandı',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_task_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Henüz alışkanlık eklemediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk alışkanlığınızı eklemek için + butonuna tıklayın',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHabit(HabitModel habit, HabitEntryModel? entry) async {
    final service = ref.read(habitServiceProvider);
    final currentValue = entry?.value ?? 0;
    final newValue = currentValue + 1;

    try {
      await service.upsertEntry(
        habitId: habit.id,
        value: newValue.clamp(0, habit.targetCount),
        target: habit.targetCount,
      );
      ref.invalidate(todayEntriesProvider);
      ref.invalidate(activeHabitsProvider);
      ref.invalidate(weeklyStatsProvider);

      if (newValue >= habit.targetCount && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${habit.name} tamamlandı!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
