import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/color_constants.dart';
import '../providers/profile_provider.dart';

class YearWrapCard extends ConsumerWidget {
  const YearWrapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return GestureDetector(
      onTap: () => _showYearWrap(context, ref),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFFFF6B2C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${now.year} Yıl Özeti',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Bu yılın istatistiklerini gör',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  void _showYearWrap(BuildContext context, WidgetRef ref) {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) return;

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0533), Color(0xFF2D1B4E), Color(0xFF0D0D14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Kapanış çubuğu
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Başlık
            Center(
              child: Column(
                children: [
                  const Text('🎆', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '${now.year} Yıl Özeti',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$dayOfYear gün geçti',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // İstatistik kartları
            _buildWrapStat(
              '🔥',
              'En İyi Seri',
              '${profile.streakRecord} gün',
              'Muhteşem bir tutarlılık!',
              const Color(0xFFFF4500),
            ),
            _buildWrapStat(
              '✅',
              'Toplam Tamamlama',
              '${profile.totalCompleted}',
              'Her biri bir adım ileri!',
              const Color(0xFF4CAF50),
            ),
            _buildWrapStat(
              '⭐',
              'Kazanılan XP',
              '${profile.xp}',
              'Seviye ${profile.level} - ${profile.levelTitle}',
              Colors.amber,
            ),
            _buildWrapStat(
              '📅',
              'Aktif Gün',
              '$dayOfYear / 365',
              '${(dayOfYear / 365 * 100).toInt()}% yıl tamamlandı',
              const Color(0xFF2196F3),
            ),
            _buildWrapStat(
              '🏆',
              'Unvan',
              profile.levelTitle,
              'Seviye ${profile.level}',
              const Color(0xFF9C27B0),
            ),

            const SizedBox(height: 24),
            // Motivasyon mesajı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text(
                    'Devam et!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${365 - dayOfYear} gün kaldı. Hedeflerine ulaşmak için harika gidiyorsun!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWrapStat(String emoji, String label, String value, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
