import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/color_constants.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Liderlik Tablosu')),
      body: leaderboardAsync.when(
        data: (leaders) {
          if (leaders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz sıralama yok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alışkanlıklarını tamamla ve\nliderlik tablosuna gir!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Top 3
              if (leaders.length >= 3)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTopPlayer(leaders[1], 2, 70),
                        const SizedBox(width: 8),
                        _buildTopPlayer(leaders[0], 1, 90),
                        const SizedBox(width: 8),
                        _buildTopPlayer(leaders[2], 3, 60),
                      ],
                    ),
                  ),
                ),

              // Rest of leaderboard
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final actualIndex = leaders.length >= 3 ? index + 3 : index;
                      if (actualIndex >= leaders.length) return null;
                      final player = leaders[actualIndex];
                      return _buildLeaderRow(player, actualIndex + 1);
                    },
                    childCount: leaders.length >= 3 ? leaders.length - 3 : leaders.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildTopPlayer(Map<String, dynamic> player, int rank, double height) {
    final medals = ['', '🥇', '🥈', '🥉'];
    final colors = [Colors.transparent, Colors.amber, Colors.grey.shade400, Colors.brown.shade300];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medals[rank], style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: rank == 1 ? 36 : 28,
          backgroundImage: player['avatar_url'] != null
              ? CachedNetworkImageProvider(player['avatar_url'])
              : null,
          child: player['avatar_url'] == null
              ? Text(
                  (player['display_name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(fontSize: rank == 1 ? 24 : 18, fontWeight: FontWeight.w700),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          player['display_name'] ?? 'Kullanıcı',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${player['xp'] ?? 0} XP',
          style: TextStyle(fontSize: 12, color: colors[rank], fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors[rank].withOpacity(0.3), colors[rank].withOpacity(0.1)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: colors[rank],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderRow(Map<String, dynamic> player, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundImage: player['avatar_url'] != null
                ? CachedNetworkImageProvider(player['avatar_url'])
                : null,
            child: player['avatar_url'] == null
                ? Text((player['display_name'] ?? '?')[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['display_name'] ?? 'Kullanıcı',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Seviye ${player['level'] ?? 1}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player['xp'] ?? 0} XP',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              Text(
                '🔥 ${player['streak_record'] ?? 0}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
