import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color_constants.dart';

/// Aylık Bingo — 25 hedeflik grid
final bingoProvider = StateNotifierProvider<BingoNotifier, Map<String, List<BingoItem>>>((ref) {
  return BingoNotifier();
});

class BingoItem {
  final String title;
  final bool completed;

  BingoItem({required this.title, this.completed = false});

  BingoItem toggle() => BingoItem(title: title, completed: !completed);
}

class BingoNotifier extends StateNotifier<Map<String, List<BingoItem>>> {
  BingoNotifier() : super({}) {
    _load();
  }

  String get _currentKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  List<BingoItem> get currentMonth => state[_currentKey] ?? [];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('bingo_months') ?? [];
    final map = <String, List<BingoItem>>{};
    for (final key in keys) {
      final items = prefs.getStringList('bingo_$key') ?? [];
      map[key] = items.map((item) {
        final parts = item.split('||');
        return BingoItem(title: parts[0], completed: parts.length > 1 && parts[1] == '1');
      }).toList();
    }
    state = map;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bingo_months', state.keys.toList());
    for (final entry in state.entries) {
      await prefs.setStringList(
        'bingo_${entry.key}',
        entry.value.map((i) => '${i.title}||${i.completed ? '1' : '0'}').toList(),
      );
    }
  }

  Future<void> addGoal(String title) async {
    final items = List<BingoItem>.from(currentMonth);
    if (items.length >= 25) return;
    items.add(BingoItem(title: title));
    state = {...state, _currentKey: items};
    await _save();
  }

  Future<void> toggleGoal(int index) async {
    final items = List<BingoItem>.from(currentMonth);
    if (index >= items.length) return;
    items[index] = items[index].toggle();
    state = {...state, _currentKey: items};
    await _save();
  }
}

const List<String> _suggestedGoals = [
  '30 dk yürüyüş', 'Kitap bitir', '2L su iç', 'Erken kalk',
  'Spor yap', 'Meditasyon', 'Yeni tarif dene', 'Arkadaşını ara',
  'Günlük yaz', 'Film izle', 'Evi temizle', 'Bitki dik',
  'Podcast dinle', 'Fotoğraf çek', 'Müzik dinle', 'Gönüllü iş',
  'Duş al', 'Meyve ye', 'Sağlıklı atıştır', 'Doğada vakit geçir',
  'Yeni kelime öğren', 'Eski eşyaları ayıkla', 'Teşekkür et',
  'Erken yat', 'Dijital detoks',
];

class BingoCard extends ConsumerWidget {
  const BingoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bingoState = ref.watch(bingoProvider);
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final items = bingoState[key] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completed = items.where((i) => i.completed).length;
    final months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🎯 ${months[now.month]} Bingo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (items.length < 25)
              TextButton.icon(
                onPressed: () => _showAddGoalDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ekle'),
              ),
          ],
        ),
        if (items.isNotEmpty) ...[
          Text(
            '$completed/${items.length} tamamlandı',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
        ],
        // 5x5 Grid
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🎲', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        const Text('Aylık hedef bingo', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          '25 hedef ekle ve ay boyunca tamamla!',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => ref.read(bingoProvider.notifier).toggleGoal(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: item.completed
                              ? AppColors.success.withOpacity(0.2)
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                          borderRadius: BorderRadius.circular(8),
                          border: item.completed
                              ? Border.all(color: AppColors.success, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              item.completed ? '✅' : item.title,
                              style: TextStyle(
                                fontSize: item.completed ? 16 : 8,
                                fontWeight: FontWeight.w500,
                                color: item.completed ? null : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bingo Hedefi Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: 'Hedefi yaz...',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Öneriler:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _suggestedGoals.map((g) => ActionChip(
                  label: Text(g, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    ref.read(bingoProvider.notifier).addGoal(g);
                    Navigator.pop(context);
                  },
                  visualDensity: VisualDensity.compact,
                )).toList(),
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
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(bingoProvider.notifier).addGoal(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
