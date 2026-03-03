import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../shared/models/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final managedAsync = ref.watch(managedProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _editing = true),
            ),
          IconButton(
            icon: const Icon(Icons.people_outlined),
            onPressed: () => context.push('/friends'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (!_editing) {
            return _buildProfileView(profile, managedAsync);
          }
          return _buildProfileEdit(profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildProfileView(ProfileModel profile, AsyncValue<List<Map<String, dynamic>>> managedAsync) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Avatar & info
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profile.avatarUrl != null
                    ? CachedNetworkImageProvider(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        (profile.displayName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName ?? 'Kullanıcı',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              if (profile.bio != null) ...[
                const SizedBox(height: 4),
                Text(profile.bio!, style: TextStyle(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seviye ${profile.level} - ${profile.levelTitle}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Stats grid
        Row(
          children: [
            _buildStatBox('XP', '${profile.xp}', Icons.star_rounded, Colors.amber),
            const SizedBox(width: 12),
            _buildStatBox('Toplam', '${profile.totalCompleted}', Icons.check_circle, AppColors.success),
            const SizedBox(width: 12),
            _buildStatBox('En İyi Seri', '${profile.streakRecord}', Icons.local_fire_department, Colors.orange),
          ],
        ),
        const SizedBox(height: 28),

        // XP Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Seviye ${profile.level}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${profile.xp % 100}/100 XP', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (profile.xp % 100) / 100,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Managed profiles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Takip Edilen Profiller',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              onPressed: _showAddManagedProfileDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ekle'),
            ),
          ],
        ),
        managedAsync.when(
          data: (profiles) {
            if (profiles.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Henüz takip edilen profil yok.\nÇocuk, eş veya aile üyesi ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return Column(
              children: profiles.map((p) => ListTile(
                leading: CircleAvatar(child: Text((p['name'] as String)[0])),
                title: Text(p['name']),
                subtitle: Text(p['relationship'] ?? 'Diğer'),
              )).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Yüklenemedi'),
        ),
        const SizedBox(height: 28),

        // Sign out
        OutlinedButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProfileEdit(ProfileModel profile) {
    _nameController.text = profile.displayName ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedGender ??= profile.gender;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'İsim'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(labelText: 'Hakkımda'),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(labelText: 'Cinsiyet'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Erkek')),
            DropdownMenuItem(value: 'female', child: Text('Kadın')),
            DropdownMenuItem(value: 'other', child: Text('Diğer')),
            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Belirtmek istemiyorum')),
          ],
          onChanged: (val) => _selectedGender = val,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _editing = false),
                child: const Text('İptal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      await ref.read(profileServiceProvider).updateProfile({
        'display_name': _nameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'gender': _selectedGender,
      });
      ref.invalidate(profileProvider);
      setState(() => _editing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showAddManagedProfileDialog() {
    final nameCtrl = TextEditingController();
    String relationship = 'child';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profil Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: relationship,
              decoration: const InputDecoration(labelText: 'İlişki'),
              items: const [
                DropdownMenuItem(value: 'child', child: Text('Çocuk')),
                DropdownMenuItem(value: 'spouse', child: Text('Eş')),
                DropdownMenuItem(value: 'parent', child: Text('Ebeveyn')),
                DropdownMenuItem(value: 'other', child: Text('Diğer')),
              ],
              onChanged: (val) => relationship = val ?? 'other',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                await ref.read(profileServiceProvider).addManagedProfile({
                  'name': nameCtrl.text,
                  'relationship': relationship,
                });
                ref.invalidate(managedProfilesProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    }
  }
}
