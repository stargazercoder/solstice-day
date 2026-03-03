import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_constants.dart';
import '../../home/providers/home_provider.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController();

  String _frequency = 'daily';
  List<int> _customDays = [];
  String _selectedColor = '#6C63FF';
  String _selectedIcon = 'check_circle';
  bool _isPublic = false;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  DateTime? _endDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetHabitsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlık Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Hazır Şablonlar'),
            Tab(text: 'Özel Oluştur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Preset habits
          presetsAsync.when(
            data: (presets) => _buildPresetsTab(presets),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),

          // TAB 2: Custom habit
          _buildCustomTab(),
        ],
      ),
    );
  }

  Widget _buildPresetsTab(List<PresetHabitModel> presets) {
    final popular = presets.where((p) => p.isPopular).toList();
    final others = presets.where((p) => !p.isPopular).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (popular.isNotEmpty) ...[
          const Text(
            '⭐ Popüler',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...popular.map((p) => _buildPresetTile(p)),
          const SizedBox(height: 24),
        ],
        const Text(
          'Tümü',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...others.map((p) => _buildPresetTile(p)),
      ],
    );
  }

  Widget _buildPresetTile(PresetHabitModel preset) {
    Color presetColor;
    try {
      presetColor = Color(int.parse(preset.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      presetColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: presetColor.withOpacity(0.06),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: presetColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.check_circle, color: presetColor, size: 22),
        ),
        title: Text(
          preset.nameTr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: preset.descriptionTr != null
            ? Text(
                preset.descriptionTr!,
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: Text(
          '${preset.defaultTargetCount} ${preset.defaultUnit ?? ''}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        onTap: () => _addPresetHabit(preset),
      ),
    );
  }

  Widget _buildCustomTab() {
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Alışkanlık Adı *',
            hintText: 'örn: Günde 2 litre su iç',
            prefixIcon: Icon(Icons.edit_rounded),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'Açıklama (opsiyonel)',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Target & Unit
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hedef',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Birim (opsiyonel)',
                  hintText: 'bardak, dk, sayfa',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Frequency
        const Text(
          'Sıklık',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'daily', label: Text('Günlük')),
            ButtonSegment(value: 'weekly', label: Text('Haftalık')),
            ButtonSegment(value: 'custom', label: Text('Özel')),
          ],
          selected: {_frequency},
          onSelectionChanged: (val) => setState(() => _frequency = val.first),
        ),

        if (_frequency == 'custom') ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final selected = _customDays.contains(i);
              return FilterChip(
                label: Text(dayNames[i]),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _customDays.add(i);
                    } else {
                      _customDays.remove(i);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }),
          ),
        ],
        const SizedBox(height: 24),

        // Color picker
        const Text(
          'Renk',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppColors.habitColors.map((c) {
            final hex = '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
            final isSelected = hex == _selectedColor.toUpperCase();
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = hex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8)]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Reminder
        SwitchListTile(
          title: const Text('Hatırlatıcı'),
          subtitle: _reminderTime != null
              ? Text('${_reminderTime!.hour}:${_reminderTime!.minute.toString().padLeft(2, '0')}')
              : null,
          value: _reminderEnabled,
          onChanged: (val) async {
            if (val) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _reminderEnabled = true;
                  _reminderTime = time;
                });
              }
            } else {
              setState(() {
                _reminderEnabled = false;
                _reminderTime = null;
              });
            }
          },
        ),

        // End date
        ListTile(
          title: const Text('Bitiş Tarihi (opsiyonel)'),
          subtitle: _endDate != null
              ? Text('${_endDate!.day}.${_endDate!.month}.${_endDate!.year}')
              : const Text('Süresiz'),
          trailing: const Icon(Icons.calendar_today_rounded),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) setState(() => _endDate = date);
          },
        ),

        // Public toggle
        SwitchListTile(
          title: const Text('Liderlik Tablosu'),
          subtitle: const Text('Herkese açık sıralamada görünsün'),
          value: _isPublic,
          onChanged: (val) => setState(() => _isPublic = val),
        ),

        const SizedBox(height: 24),

        // Save button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveCustomHabit,
            child: _saving
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white,
                    ),
                  )
                : const Text('Alışkanlığı Oluştur'),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Future<void> _addPresetHabit(PresetHabitModel preset) async {
    setState(() => _saving = true);
    try {
      final service = ref.read(habitServiceProvider);
      await service.createHabit({
        'preset_id': preset.id,
        'category_id': preset.categoryId,
        'name': preset.nameTr,
        'description': preset.descriptionTr,
        'icon': preset.icon,
        'color': preset.color,
        'frequency': preset.defaultFrequency,
        'target_count': preset.defaultTargetCount,
        'unit': preset.defaultUnit,
        'start_date': DateTime.now().toIso8601String().split('T').first,
      });
      ref.invalidate(activeHabitsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${preset.nameTr} eklendi!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveCustomHabit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir isim girin')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(habitServiceProvider);
      await service.createHabit({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'icon': _selectedIcon,
        'color': _selectedColor,
        'frequency': _frequency,
        'custom_days': _customDays,
        'target_count': int.tryParse(_targetController.text) ?? 1,
        'unit': _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        'start_date': DateTime.now().toIso8601String().split('T').first,
        'end_date': _endDate?.toIso8601String().split('T').first,
        'reminder_enabled': _reminderEnabled,
        'reminder_time': _reminderTime != null
            ? '${_reminderTime!.hour}:${_reminderTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'is_public': _isPublic,
      });
      ref.invalidate(activeHabitsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alışkanlık oluşturuldu!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
