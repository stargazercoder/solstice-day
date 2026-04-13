import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/notebook') return 1;
    if (location == '/calendar') return 2;
    if (location == '/chains') return 3;
    if (location == '/leaderboard') return 4;
    if (location == '/profile') return 5;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/notebook');
      case 2: context.go('/calendar');
      case 3: context.go('/chains');
      case 4: context.go('/leaderboard');
      case 5: context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIdx = _currentIndex(context);

    return Scaffold(
      body: child,
      floatingActionButton: currentIdx == 0
          ? FloatingActionButton(
              onPressed: () => context.push('/add-habit'),
              elevation: 4,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Ana Sayfa',
                  isActive: currentIdx == 0,
                  color: AppColors.primary,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Defter',
                  isActive: currentIdx == 1,
                  color: AppColors.sectionDiary,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Takvim',
                  isActive: currentIdx == 2,
                  color: AppColors.info,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Zincirler',
                  isActive: currentIdx == 3,
                  color: AppColors.streakFire,
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Sıralama',
                  isActive: currentIdx == 4,
                  color: AppColors.accent,
                  onTap: () => _onTap(context, 4),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  isActive: currentIdx == 5,
                  color: AppColors.sectionGoals,
                  onTap: () => _onTap(context, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isActive
            ? BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? color : AppColors.textHint,
              size: isActive ? 24 : 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? color : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
