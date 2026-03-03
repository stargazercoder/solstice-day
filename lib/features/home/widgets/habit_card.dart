import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/color_constants.dart';
import '../../habits/models/habit_model.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final HabitEntryModel? entry;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const HabitCard({
    super.key,
    required this.habit,
    this.entry,
    required this.onTap,
    required this.onComplete,
  });

  Color get _habitColor {
    try {
      return Color(int.parse(habit.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData get _habitIcon {
    // Map common icon names to Material icons
    final iconMap = <String, IconData>{
      'water_drop': Icons.water_drop,
      'fitness_center': Icons.fitness_center,
      'menu_book': Icons.menu_book,
      'self_improvement': Icons.self_improvement,
      'alarm': Icons.alarm,
      'edit_note': Icons.edit_note,
      'directions_walk': Icons.directions_walk,
      'restaurant': Icons.restaurant,
      'translate': Icons.translate,
      'check_circle': Icons.check_circle,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'spa': Icons.spa,
      'brush': Icons.brush,
      'phone_disabled': Icons.phone_disabled,
      'medication': Icons.medication,
      'savings': Icons.savings,
    };
    return iconMap[habit.icon] ?? Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentValue = entry?.value ?? 0;
    final progress = habit.targetCount > 0
        ? (currentValue / habit.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = currentValue >= habit.targetCount;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? _habitColor.withOpacity(0.1)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? _habitColor.withOpacity(0.3)
                : (isDark ? AppColors.darkSurfaceVariant : AppColors.divider),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? _habitColor : Colors.black).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _habitColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_habitIcon, color: _habitColor, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? AppColors.textSecondary
                                : null,
                          ),
                        ),
                      ),
                      if (habit.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 2),
                              Text(
                                '${habit.currentStreak}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: 6,
                          percent: progress,
                          backgroundColor: _habitColor.withOpacity(0.1),
                          progressColor: _habitColor,
                          barRadius: const Radius.circular(3),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentValue/${habit.targetCount}${habit.unit != null ? ' ${habit.unit}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Action button
            GestureDetector(
              onTap: isCompleted ? null : onComplete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? _habitColor : _habitColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.add_rounded,
                  color: isCompleted ? Colors.white : _habitColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
