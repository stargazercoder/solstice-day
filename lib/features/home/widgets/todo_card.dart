import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/color_constants.dart';

class TodoItem {
  final String id;
  final String title;
  final String category;
  final String priority; // high, normal, low
  final bool completed;

  TodoItem({
    required this.id,
    required this.title,
    this.category = 'daily',
    this.priority = 'normal',
    this.completed = false,
  });

  TodoItem toggle() => TodoItem(
        id: id,
        title: title,
        category: category,
        priority: priority,
        completed: !completed,
      );
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<TodoItem>> {
  TodoNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final data = prefs.getStringList('todos_$today') ?? [];
    final items = data.map((item) {
      final parts = item.split('||');
      return TodoItem(
        id: parts[0],
        title: parts.length > 1 ? parts[1] : '',
        category: parts.length > 2 ? parts[2] : 'daily',
        priority: parts.length > 3 ? parts[3] : 'normal',
        completed: parts.length > 4 && parts[4] == '1',
      );
    }).toList();
    state = items;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> addItem(String title, String category, String priority) async {
    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      priority: priority,
    );
    state = [...state, item];
    await _save();
  }

  Future<void> toggleItem(String id) async {
    state = state.map((item) => item.id == id ? item.toggle() : item).toList();
    await _save();
  }

  Future<void> removeItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((item) {
      return '${item.id}||${item.title}||${item.category}||${item.priority}||${item.completed ? '1' : '0'}';
    }).toList();
    await prefs.setStringList('todos_${_todayKey()}', data);
  }
}

class TodoCard extends ConsumerWidget {
  const TodoCard({super.key});

  static const _categoryLabels = {
    'daily': '📋 Günlük',
    'education': '📖 Eğitim',
    'shopping': '🛒 Alışveriş',
    'work': '💼 İş',
    'personal': '👤 Kişisel',
    'other': '📌 Diğer',
  };

  static const _priorityColors = {
    'high': AppColors.error,
    'normal': AppColors.info,
    'low': AppColors.textHint,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = todos.where((t) => !t.completed).length;
    final done = todos.where((t) => t.completed).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text('Görevler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  if (todos.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pending > 0 ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$done/${ todos.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: pending > 0 ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                onPressed: () => _showAddTodoDialog(context, ref),
                icon: const Icon(Icons.add_circle_outline, size: 22),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          if (todos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Bugün için görev yok. + ile ekleyin!',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            // Pending items first, then completed
            ...todos.where((t) => !t.completed).map((item) => _buildTodoItem(context, ref, item, isDark)),
            if (done > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Tamamlanan ($done)',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              ),
              ...todos.where((t) => t.completed).map((item) => _buildTodoItem(context, ref, item, isDark)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, WidgetRef ref, TodoItem item, bool isDark) {
    final priorityColor = _priorityColors[item.priority] ?? AppColors.info;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(todoProvider.notifier).removeItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error.withOpacity(0.1),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            // Priority dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            // Checkbox
            GestureDetector(
              onTap: () => ref.read(todoProvider.notifier).toggleItem(item.id),
              child: Icon(
                item.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                size: 20,
                color: item.completed ? AppColors.success : AppColors.textHint,
              ),
            ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  decoration: item.completed ? TextDecoration.lineThrough : null,
                  color: item.completed ? AppColors.textHint : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String category = 'daily';
    String priority = 'normal';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Yeni Görev', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Görev...', prefixIcon: Icon(Icons.task_alt)),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    ref.read(todoProvider.notifier).addItem(val.trim(), category, priority);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Kategori
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _categoryLabels.entries.map((e) => ChoiceChip(
                  label: Text(e.value, style: const TextStyle(fontSize: 11)),
                  selected: category == e.key,
                  onSelected: (_) => setState(() => category = e.key),
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
              const SizedBox(height: 8),
              // Öncelik
              Row(
                children: [
                  const Text('Öncelik: ', style: TextStyle(fontSize: 12)),
                  ...['high', 'normal', 'low'].map((p) {
                    final labels = {'high': 'Yüksek', 'normal': 'Normal', 'low': 'Düşük'};
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(labels[p]!, style: const TextStyle(fontSize: 11)),
                        selected: priority == p,
                        onSelected: (_) => setState(() => priority = p),
                        visualDensity: VisualDensity.compact,
                        selectedColor: _priorityColors[p]?.withOpacity(0.2),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      ref.read(todoProvider.notifier).addItem(ctrl.text.trim(), category, priority);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
