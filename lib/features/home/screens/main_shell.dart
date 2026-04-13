import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
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
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        color: isDark ? Colors.white : Colors.black,
        buttonBackgroundColor: AppColors.primary,
        height: 70,
        items: [
          CurvedNavigationBarItem(
            label: 'Ana Sayfa',
            child: currentIdx == 0 ? const Icon(Icons.home_rounded) : const Icon(Icons.home_outlined),
          ),
          CurvedNavigationBarItem(
            label: 'Defter',
            child: currentIdx == 1 ? const Icon(Icons.auto_stories_rounded) : const Icon(Icons.auto_stories_outlined),
          ),
          CurvedNavigationBarItem(
            label: 'Takvim',
            child: currentIdx == 2 ? const Icon(Icons.calendar_month_rounded) : const Icon(Icons.calendar_month_outlined),
          ),
          CurvedNavigationBarItem(
            label: 'Zincirler',
            child: currentIdx == 3 ? const Icon(Icons.local_fire_department_rounded) : const Icon(Icons.local_fire_department_outlined),
          ),
          CurvedNavigationBarItem(
            label: 'Sıralama',
            child: currentIdx == 4 ? const Icon(Icons.emoji_events_rounded) : const Icon(Icons.emoji_events_outlined),
          ),
          CurvedNavigationBarItem(
            label: 'Profil',
            child: currentIdx == 5 ? const Icon(Icons.person_rounded) : const Icon(Icons.person_outline),
          ),
        ],
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}
