import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/services/supabase_service.dart';

// Mock data for when Supabase is not available
final _mockSections = [
  {'id': '1', 'name': 'Genel', 'icon': 'notes', 'color': '#3B82F6', 'sort_order': 0},
  {'id': '2', 'name': 'Fitness', 'icon': 'fitness_center', 'color': '#EF4444', 'sort_order': 1},
  {'id': '3', 'name': 'Beslenme', 'icon': 'restaurant', 'color': '#84CC16', 'sort_order': 2},
  {'id': '4', 'name': 'Kitaplar', 'icon': 'menu_book', 'color': '#8B5CF6', 'sort_order': 3},
  {'id': '5', 'name': 'Hedefler', 'icon': 'flag', 'color': '#F97316', 'sort_order': 4},
];

final _mockEntries = <String, List<Map<String, dynamic>>>{
  '1': [
    {'id': 'e1', 'title': 'Günlük Plan', 'content': 'Sabah koşusu 30 dakika\nKitap oku 20 sayfa\nSu iç 8 bardak', 'entry_type': 'text', 'is_pinned': true},
    {'id': 'e2', 'title': 'Alışveriş Listesi', 'content': '', 'entry_type': 'checklist', 'checklist_items': [
      {'text': 'Süt', 'checked': true},
      {'text': 'Ekmek', 'checked': false},
      {'text': 'Yumurta', 'checked': true},
    ]},
    {'id': 'e3', 'title': 'Haftalık Hedefler', 'content': '3 kitap bitirmek\n5 kilo vermek\nMeditasyon yapmak', 'entry_type': 'text', 'is_pinned': false},
  ],
  '2': [
    {'id': 'e4', 'title': 'Egzersiz Programı', 'content': 'Pazartesi: Koşu\nSalı: Yüzme\nÇarşamba: Ağırlık', 'entry_type': 'text', 'is_pinned': false},
  ],
  '3': [
    {'id': 'e5', 'title': 'Beslenme Planı', 'content': 'Kahvaltı: Yulaf, meyve\nÖğle: Tavuk, salata\nAkşam: Sebze, balık', 'entry_type': 'text', 'is_pinned': false},
  ],
  '4': [
    {'id': 'e6', 'title': 'Okunan Kitaplar', 'content': '1. Atomik Alışkanlıklar\n2. Derin Çalışma\n3. Egoist Olmanın Faydası', 'entry_type': 'text', 'is_pinned': false},
  ],
  '5': [
    {'id': 'e7', 'title': '2024 Hedefleri', 'content': '', 'entry_type': 'checklist', 'checklist_items': [
      {'text': 'İngilizce B2 seviyesi', 'checked': false},
      {'text': 'Maraton tamamlama', 'checked': false},
      {'text': '10 kitap okuma', 'checked': true},
    ]},
  ],
};

// Providers with fallback to mock data
final notebookSectionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('No user');
    final res = await SupabaseService.client
        .from('notebook_sections')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    final data = List<Map<String, dynamic>>.from(res);
    // If no sections exist, use mock data
    if (data.isEmpty) {
      return _mockSections;
    }
    return data;
  } catch (e) {
    // Fallback to mock data on error
    return _mockSections;
  }
});

final notebookEntriesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, sectionId) async {
  try {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('No user');
    final res = await SupabaseService.client
        .from('notebook_entries')
        .select()
        .eq('user_id', userId)
        .eq('section_id', sectionId)
        .order('is_pinned', ascending: false)
        .order('updated_at', ascending: false);
    final data = List<Map<String, dynamic>>.from(res);
    // If no entries exist, use mock data
    if (data.isEmpty && _mockEntries.containsKey(sectionId)) {
      return _mockEntries[sectionId]!;
    }
    return data;
  } catch (e) {
    // Fallback to mock data on error
    return _mockEntries[sectionId] ?? [];
  }
});

class NotebookScreen extends ConsumerStatefulWidget {
  const NotebookScreen({super.key});

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  int _selectedSection = 0;

  final _sectionIcons = <String, IconData>{
    'book': Icons.auto_stories_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'restaurant': Icons.restaurant_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'menu_book': Icons.menu_book_rounded,
    'flag': Icons.flag_rounded,
    'notes': Icons.sticky_note_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(notebookSectionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Defterim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEntryDialog(context, ref),
          ),
        ],
      ),
      body: sectionsAsync.when(
        data: (sections) {
          if (sections.isEmpty) {
            return const Center(child: Text('Bölümler yükleniyor...'));
          }
          final currentSection = sections[_selectedSection];
          final sectionId = currentSection['id'] as String;

          return Row(
            children: [
              // Ana içerik
              Expanded(
                child: _buildSectionContent(sectionId, currentSection, isDark),
              ),

              // Sağ taraf — Fihrist tabları
              _buildFihrist(sections, isDark),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildFihrist(List<Map<String, dynamic>> sections, bool isDark) {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          left: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final isActive = _selectedSection == index;

          Color sectionColor;
          try {
            sectionColor = Color(int.parse((section['color'] as String).replaceFirst('#', '0xFF')));
          } catch (_) {
            sectionColor = AppColors.primary;
          }

          final iconData = _sectionIcons[section['icon']] ?? Icons.notes_rounded;

          return GestureDetector(
            onTap: () => setState(() => _selectedSection = index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? sectionColor : sectionColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 18,
                    color: isActive ? Colors.white : sectionColor,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (section['name'] as String).split(' ').first,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : sectionColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContent(String sectionId, Map<String, dynamic> section, bool isDark) {
    final entriesAsync = ref.watch(notebookEntriesProvider(sectionId));
    final sectionName = section['name'] ?? 'Not';

    Color sectionColor;
    try {
      sectionColor = Color(int.parse((section['color'] as String).replaceFirst('#', '0xFF')));
    } catch (_) {
      sectionColor = AppColors.primary;
    }

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.note_add_rounded, size: 36, color: sectionColor),
                ),
                const SizedBox(height: 16),
                Text(
                  '$sectionName bölümü boş',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sağ üstteki + butonu ile not ekleyin',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildEntryCard(entry, sectionColor, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, Color sectionColor, bool isDark) {
    final title = entry['title'] ?? '';
    final content = entry['content'] ?? '';
    final type = entry['entry_type'] ?? 'text';
    final isPinned = entry['is_pinned'] == true;
    final checklist = (entry['checklist_items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPinned ? sectionColor.withOpacity(0.3) : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              if (isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.push_pin_rounded, size: 14, color: sectionColor),
                ),
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Başlıksız not',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: title.isEmpty ? AppColors.textHint : null,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, size: 18, color: AppColors.textHint),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'pin', child: Text(isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle')),
                  const PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                ],
                onSelected: (val) => _handleEntryAction(val, entry),
              ),
            ],
          ),

          // İçerik
          if (type == 'checklist' && checklist.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...checklist.take(5).map((item) {
              final checked = item['checked'] == true;
              final text = item['text'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: checked ? sectionColor : AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          decoration: checked ? TextDecoration.lineThrough : null,
                          color: checked ? AppColors.textHint : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (checklist.length > 5)
              Text(
                '+${checklist.length - 5} öğe daha',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ] else if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.read(notebookSectionsProvider);
    final sections = sectionsAsync.valueOrNull ?? [];
    if (sections.isEmpty) return;

    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String entryType = 'text';
    String selectedSectionId = sections[_selectedSection]['id'];
    final checkItems = <String>[];
    final checkCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Not',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              // Not türü
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'text', icon: Icon(Icons.text_fields, size: 16), label: Text('Metin')),
                  ButtonSegment(value: 'checklist', icon: Icon(Icons.checklist, size: 16), label: Text('Liste')),
                ],
                selected: {entryType},
                onSelectionChanged: (val) => setState(() => entryType = val.first),
              ),
              const SizedBox(height: 12),
              // Başlık
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Not başlığı...',
                ),
              ),
              const SizedBox(height: 12),

              if (entryType == 'text')
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'İçerik',
                    hintText: 'Notunuzu yazın...',
                  ),
                  maxLines: 4,
                ),

              if (entryType == 'checklist') ...[
                ...checkItems.asMap().entries.map((e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_box_outline_blank, size: 20),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => checkItems.removeAt(e.key)),
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: checkCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Öğe ekle...',
                          isDense: true,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setState(() => checkItems.add(val.trim()));
                            checkCtrl.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (checkCtrl.text.trim().isNotEmpty) {
                          setState(() => checkItems.add(checkCtrl.text.trim()));
                          checkCtrl.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Mock data'ya ekle (Supabase yoksa)
                    final mockEntry = {
                      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
                      'title': titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
                      'content': entryType == 'text' ? contentCtrl.text.trim() : null,
                      'entry_type': entryType,
                      'checklist_items': entryType == 'checklist'
                          ? checkItems.map((t) => {'text': t, 'checked': false}).toList()
                          : [],
                      'is_pinned': false,
                    };

                    // Supabase'e kaydetmeyi dene
                    try {
                      final userId = SupabaseService.currentUserId;
                      if (userId != null) {
                        await SupabaseService.client.from('notebook_entries').insert({
                          'user_id': userId,
                          'section_id': selectedSectionId,
                          'title': titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
                          'content': entryType == 'text' ? contentCtrl.text.trim() : null,
                          'entry_type': entryType,
                          'checklist_items': entryType == 'checklist'
                              ? checkItems.map((t) => {'text': t, 'checked': false}).toList()
                              : [],
                        });
                      }
                    } catch (_) {
                      // Supabase hatası - mock data'ya ekle
                      if (_mockEntries.containsKey(selectedSectionId)) {
                        _mockEntries[selectedSectionId]!.insert(0, mockEntry);
                      } else {
                        _mockEntries[selectedSectionId] = [mockEntry];
                      }
                    }

                    ref.invalidate(notebookEntriesProvider(selectedSectionId));
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEntryAction(String action, Map<String, dynamic> entry) async {
    final entryId = entry['id'] as String;
    final sectionId = entry['section_id'] ?? entry['sectionId'] as String? ?? '1';

    switch (action) {
      case 'pin':
        try {
          await SupabaseService.client
              .from('notebook_entries')
              .update({'is_pinned': !(entry['is_pinned'] == true)})
              .eq('id', entryId);
        } catch (_) {
          // Mock data'da güncelle
          for (var i = 0; i < _mockEntries.length; i++) {
            final entries = _mockEntries[_mockEntries.keys.elementAt(i)] ?? [];
            for (var j = 0; j < entries.length; j++) {
              if (entries[j]['id'] == entryId) {
                entries[j]['is_pinned'] = !(entries[j]['is_pinned'] == true);
                _mockEntries[_mockEntries.keys.elementAt(i)] = entries;
                break;
              }
            }
          }
        }
        ref.invalidate(notebookEntriesProvider(sectionId));
        break;
      case 'delete':
        try {
          await SupabaseService.client
              .from('notebook_entries')
              .delete()
              .eq('id', entryId);
        } catch (_) {
          // Mock data'dan sil
          for (var key in _mockEntries.keys) {
            _mockEntries[key]?.removeWhere((e) => e['id'] == entryId);
          }
        }
        ref.invalidate(notebookEntriesProvider(sectionId));
        break;
    }
  }
}
