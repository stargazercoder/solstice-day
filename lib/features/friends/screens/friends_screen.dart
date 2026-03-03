import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/color_constants.dart';
import '../providers/friend_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _inviteCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);
    final pendingAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Invite section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.group_add_rounded, color: Colors.white, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'Arkadaşlarını Davet Et!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Birlikte alışkanlık edinin, birbirinizi motive edin',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateAndShareInvite,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Davet Kodu Paylaş'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _showEnterCodeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kod Gir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pending requests
          pendingAsync.when(
            data: (pending) {
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bekleyen İstekler (${pending.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...pending.map((req) => _buildPendingRequest(req)),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Friends list
          const Text(
            'Arkadaşlarım',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          friendsAsync.when(
            data: (friends) {
              if (friends.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('👥', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Henüz arkadaş eklenmemiş',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Davet kodunu paylaşarak başlayabilirsin',
                        style: TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: friends.map((f) => _buildFriendTile(f)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Hata: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequest(Map<String, dynamic> req) {
    final requester = req['requester'] as Map<String, dynamic>?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child: Text((requester?['display_name'] ?? '?')[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              requester?['display_name'] ?? 'Kullanıcı',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: AppColors.success),
            onPressed: () async {
              await ref.read(friendServiceProvider).acceptFriendRequest(req['id']);
              ref.invalidate(pendingRequestsProvider);
              ref.invalidate(friendsProvider);
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: AppColors.error),
            onPressed: () async {
              await ref.read(friendServiceProvider).rejectFriendRequest(req['id']);
              ref.invalidate(pendingRequestsProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friendship) {
    // Determine which profile is the friend
    final requester = friendship['requester'] as Map<String, dynamic>?;
    final addressee = friendship['addressee'] as Map<String, dynamic>?;
    final friend = requester ?? addressee;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).cardColor,
        leading: CircleAvatar(
          child: Text((friend?['display_name'] ?? '?')[0].toUpperCase()),
        ),
        title: Text(friend?['display_name'] ?? 'Kullanıcı'),
        subtitle: Text(
          'Seviye ${friend?['level'] ?? 1} · ${friend?['total_completed'] ?? 0} tamamlama',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Text(
          '🔥 ${friend?['streak_record'] ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _generateAndShareInvite() async {
    try {
      final code = await ref.read(friendServiceProvider).createInviteCode();
      await Share.share(
        'Habitra\'da alışkanlıklarımızı birlikte takip edelim! 🎯\n\nDavet kodum: $code\n\nUygulamayı indir ve bu kodu gir!',
        subject: 'Habitra - Alışkanlık Takip Daveti',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showInviteDialog() {
    _generateAndShareInvite();
  }

  void _showEnterCodeDialog() {
    _inviteCodeController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Davet Kodu Gir'),
        content: TextField(
          controller: _inviteCodeController,
          decoration: const InputDecoration(
            hintText: 'ABCD1234',
            prefixIcon: Icon(Icons.vpn_key_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = _inviteCodeController.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(context);
              try {
                final result = await ref.read(friendServiceProvider).useInviteCode(code);
                if (result != null) {
                  ref.invalidate(friendsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Arkadaşlık isteği gönderildi!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Geçersiz veya süresi dolmuş kod'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Kullan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }
}
