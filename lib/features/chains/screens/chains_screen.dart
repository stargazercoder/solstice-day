import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/bingo_card.dart';

// Providers
final streakRewardsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await SupabaseService.client
      .from('streak_rewards')
      .select()
      .order('streak_days');
  return List<Map<String, dynamic>>.from(res);
});

final userRewardsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  final res = await SupabaseService.client
      .from('user_rewards')
      .select('*, streak_rewards(*)')
      .eq('user_id', userId);
  return List<Map<String, dynamic>>.from(res);
});

final userGoalsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return [];
  final res = await SupabaseService.client
      .from('goals')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(res);
});

final userStreakStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = SupabaseService.currentUserId;
  if (userId == null) return {};
  final profile = await SupabaseService.client
      .from('profiles')
      .select('xp, level, streak_record, total_completed')
      .eq('id', userId)
      .single();
  // En uzun aktif streak
  final habits = await SupabaseService.client
      .from('habits')
      .select('current_streak, best_streak, name, color, icon')
      .eq('user_id', userId)
      .eq('is_active', true)
      .order('current_streak', ascending: false);
  return {
    ...profile,
    'habits': List<Map<String, dynamic>>.from(habits),
  };
});

class ChainsScreen extends ConsumerWidget {
  const ChainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStreakStatsProvider);
    final rewardsAsync = ref.watch(streakRewardsProvider);
    final earnedAsync = ref.watch(userRewardsProvider);
    final goalsAsync = ref.watch(userGoalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Zincirlerim')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStreakStatsProvider);
          ref.invalidate(streakRewardsProvider);
          ref.invalidate(userRewardsProvider);
          ref.invalidate(userGoalsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Streak Ateşi Kartı
            statsAsync.when(
              data: (stats) => _buildStreakFireCard(context, stats, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Aktif Zincirler
            const Text(
              '🔗 Aktif Zincirler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) {
                final habits = (stats['habits'] as List<Map<String, dynamic>>?) ?? [];
                if (habits.isEmpty) {
                  return _buildEmptyCard(
                    '🔥',
                    'Henüz aktif zincir yok',
                    'Alışkanlık ekle ve zincirleri oluşturmaya başla!',
                  );
                }
                return Column(
                  children: habits.map((h) => _buildChainTile(context, h, isDark)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Yüklenemedi'),
            ),
            const SizedBox(height: 24),

            // Hedeflerim
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🎯 Hedeflerim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton.icon(
                  onPressed: () => _showAddGoalDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            goalsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return _buildEmptyCard(
                    '🎯',
                    'Henüz hedef yok',
                    'Yıllık, aylık veya haftalık hedef belirle!',
                  );
                }
                return Column(
                  children: goals.map((g) => _buildGoalTile(context, g, isDark)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Yüklenemedi'),
            ),
            const SizedBox(height: 24),

            // Aylık Bingo
            const BingoCard(),
            const SizedBox(height: 24),

            // Ödüller Haritası
            const Text(
              '🏆 Ödül Yolculuğu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            rewardsAsync.when(
              data: (rewards) {
                final earned = earnedAsync.valueOrNull ?? [];
                final earnedIds = earned.map((e) => e['reward_id']).toSet();
                final maxStreak = statsAsync.valueOrNull?['streak_record'] ?? 0;
                return _buildRewardTimeline(context, rewards, earnedIds, maxStreak, isDark);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Yüklenemedi'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakFireCard(BuildContext context, Map<String, dynamic> stats, bool isDark) {
    final habits = (stats['habits'] as List<Map<String, dynamic>>?) ?? [];
    final longestCurrent = habits.isNotEmpty
        ? habits.map((h) => (h['current_streak'] as int?) ?? 0).reduce((a, b) => a > b ? a : b)
        : 0;
    final record = (stats['streak_record'] as int?) ?? 0;
    final xp = (stats['xp'] as int?) ?? 0;
    final level = (stats['level'] as int?) ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4500), Color(0xFFFF6B2C), Color(0xFFFFD93D)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Büyük streak sayısı
          Text(
            '🔥 $longestCurrent',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Text(
            'Günlük Seri',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Alt istatistikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFireStat('Rekor', '$record 🏆', Colors.white),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildFireStat('XP', '$xp ⭐', Colors.white),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildFireStat('Seviye', '$level', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFireStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildChainTile(BuildContext context, Map<String, dynamic> habit, bool isDark) {
    final name = habit['name'] ?? '';
    final current = (habit['current_streak'] as int?) ?? 0;
    final best = (habit['best_streak'] as int?) ?? 0;
    Color habitColor;
    try {
      habitColor = Color(int.parse((habit['color'] as String).replaceFirst('#', '0xFF')));
    } catch (_) {
      habitColor = AppColors.primary;
    }

    // Bir sonraki ödül
    final nextMilestones = [3, 7, 14, 30, 60, 100, 180, 365];
    final nextMilestone = nextMilestones.firstWhere((m) => m > current, orElse: () => 365);
    final progress = nextMilestone > 0 ? (current / nextMilestone).clamp(0.0, 1.0) : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: current > 0 ? habitColor.withOpacity(0.3) : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Zincir ikonu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    current > 0 ? '🔥' : '⛓️',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      current > 0
                          ? '$current gün devam ediyor · Rekor: $best'
                          : 'Bugün başla!',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Streak sayısı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: current > 0 ? habitColor.withOpacity(0.12) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$current',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: current > 0 ? habitColor : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
          if (current > 0) ...[
            const SizedBox(height: 10),
            // Sonraki milestone progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: habitColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(habitColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$current/$nextMilestone',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalTile(BuildContext context, Map<String, dynamic> goal, bool isDark) {
    final title = goal['title'] ?? '';
    final type = goal['goal_type'] ?? 'yearly';
    final current = (goal['current_value'] as int?) ?? 0;
    final target = (goal['target_value'] as int?) ?? 1;
    final unit = goal['unit'] ?? '';
    final isCompleted = goal['is_completed'] == true;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    Color goalColor;
    try {
      goalColor = Color(int.parse((goal['color'] as String).replaceFirst('#', '0xFF')));
    } catch (_) {
      goalColor = AppColors.primary;
    }

    final typeLabels = {'yearly': '🗓️ Yıllık', 'monthly': '📅 Aylık', 'weekly': '📆 Haftalık'};
    final typeEmoji = typeLabels[type] ?? '🎯';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? goalColor.withOpacity(0.08)
            : (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted ? goalColor.withOpacity(0.3) : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: goalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeEmoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (isCompleted)
                const Text('✅', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: goalColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(goalColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$current/$target ${unit.isNotEmpty ? unit : ''}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: goalColor,
                ),
              ),
            ],
          ),
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${(progress * 100).toInt()}% tamamlandı',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardTimeline(
    BuildContext context,
    List<Map<String, dynamic>> rewards,
    Set earnedIds,
    int maxStreak,
    bool isDark,
  ) {
    return Column(
      children: rewards.map((reward) {
        final isEarned = earnedIds.contains(reward['id']);
        final streakDays = (reward['streak_days'] as int?) ?? 0;
        final isReachable = maxStreak >= streakDays;
        final icon = reward['icon'] ?? '🏆';
        final title = reward['title_tr'] ?? '';
        final desc = reward['description_tr'] ?? '';

        Color rewardColor;
        try {
          rewardColor = Color(int.parse((reward['color'] as String).replaceFirst('#', '0xFF')));
        } catch (_) {
          rewardColor = AppColors.accent;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Timeline çizgisi
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isEarned
                          ? rewardColor
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEarned ? rewardColor : AppColors.divider,
                        width: 2,
                      ),
                      boxShadow: isEarned
                          ? [BoxShadow(color: rewardColor.withOpacity(0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(fontSize: isEarned ? 20 : 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? rewardColor.withOpacity(0.06)
                        : (isDark ? AppColors.darkSurface : AppColors.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEarned ? rewardColor.withOpacity(0.2) : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isEarned ? rewardColor : null,
                              ),
                            ),
                            Text(
                              desc,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEarned
                              ? rewardColor.withOpacity(0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🔥$streakDays',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isEarned ? rewardColor : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCard(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  static const _goalCategories = <String, String>{
    'general': '🎯 Genel',
    'language': '🌍 Dil',
    'reading': '📚 Okuma',
    'career': '💼 Kariyer',
    'health': '🧠 Ruh Sağlığı',
    'fitness': '🏋️ Fitness',
    'finance': '💰 Finans',
    'social': '🤝 Sosyal',
    'creative': '🎨 Yaratıcılık',
  };

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController();
    final motivationCtrl = TextEditingController();
    String goalType = 'monthly';
    String category = 'general';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Hedef'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hedef *',
                    hintText: 'örn: 50 kitap oku',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                // Kategori
                const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _goalCategories.entries.map((e) {
                    final isSelected = category == e.key;
                    return ChoiceChip(
                      label: Text(e.value, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => category = e.key),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'weekly', label: Text('Haftalık')),
                    ButtonSegment(value: 'monthly', label: Text('Aylık')),
                    ButtonSegment(value: 'yearly', label: Text('Yıllık')),
                  ],
                  selected: {goalType},
                  onSelectionChanged: (val) => setState(() => goalType = val.first),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hedef Sayı'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Birim',
                          hintText: 'kitap, km, saat',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: motivationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivasyon notu (opsiyonel)',
                    hintText: 'Bu hedef benim için neden önemli?',
                    prefixIcon: Icon(Icons.lightbulb_outline, size: 20),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final userId = SupabaseService.currentUserId;
                if (userId == null) return;
                await SupabaseService.client.from('goals').insert({
                  'user_id': userId,
                  'title': titleCtrl.text.trim(),
                  'goal_type': goalType,
                  'target_value': int.tryParse(targetCtrl.text) ?? 1,
                  'unit': unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim(),
                  'category': category,
                  'motivation': motivationCtrl.text.trim().isEmpty ? null : motivationCtrl.text.trim(),
                });
                ref.invalidate(userGoalsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
