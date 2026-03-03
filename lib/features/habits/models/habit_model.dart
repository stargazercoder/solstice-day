class HabitModel {
  final String id;
  final String userId;
  final String? managedProfileId;
  final String? presetId;
  final String? categoryId;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String frequency;
  final List<int> customDays;
  final int targetCount;
  final String? unit;
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderEnabled;
  final String? reminderTime;
  final bool isActive;
  final bool isArchived;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final bool isPublic;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.userId,
    this.managedProfileId,
    this.presetId,
    this.categoryId,
    required this.name,
    this.description,
    this.icon = 'check_circle',
    this.color = '#6C63FF',
    this.frequency = 'daily',
    this.customDays = const [],
    this.targetCount = 1,
    this.unit,
    required this.startDate,
    this.endDate,
    this.reminderEnabled = false,
    this.reminderTime,
    this.isActive = true,
    this.isArchived = false,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.isPublic = false,
    required this.createdAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
    id: json['id'],
    userId: json['user_id'],
    managedProfileId: json['managed_profile_id'],
    presetId: json['preset_id'],
    categoryId: json['category_id'],
    name: json['name'],
    description: json['description'],
    icon: json['icon'] ?? 'check_circle',
    color: json['color'] ?? '#6C63FF',
    frequency: json['frequency'] ?? 'daily',
    customDays: json['custom_days'] != null
      ? List<int>.from(json['custom_days'])
      : [],
    targetCount: json['target_count'] ?? 1,
    unit: json['unit'],
    startDate: DateTime.parse(json['start_date']),
    endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    reminderEnabled: json['reminder_enabled'] ?? false,
    reminderTime: json['reminder_time'],
    isActive: json['is_active'] ?? true,
    isArchived: json['is_archived'] ?? false,
    currentStreak: json['current_streak'] ?? 0,
    bestStreak: json['best_streak'] ?? 0,
    totalCompletions: json['total_completions'] ?? 0,
    isPublic: json['is_public'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'managed_profile_id': managedProfileId,
    'preset_id': presetId,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'frequency': frequency,
    'custom_days': customDays,
    'target_count': targetCount,
    'unit': unit,
    'start_date': startDate.toIso8601String().split('T').first,
    'end_date': endDate?.toIso8601String().split('T').first,
    'reminder_enabled': reminderEnabled,
    'reminder_time': reminderTime,
    'is_public': isPublic,
  };

  double get completionRate {
    final daysSinceStart = DateTime.now().difference(startDate).inDays + 1;
    if (daysSinceStart <= 0) return 0;
    return (totalCompletions / daysSinceStart).clamp(0.0, 1.0);
  }
}

class HabitEntryModel {
  final String id;
  final String habitId;
  final String userId;
  final DateTime entryDate;
  final int value;
  final int target;
  final bool isCompleted;
  final int? mood;
  final String? note;
  final DateTime? completedAt;

  HabitEntryModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.entryDate,
    this.value = 0,
    this.target = 1,
    this.isCompleted = false,
    this.mood,
    this.note,
    this.completedAt,
  });

  factory HabitEntryModel.fromJson(Map<String, dynamic> json) => HabitEntryModel(
    id: json['id'],
    habitId: json['habit_id'],
    userId: json['user_id'],
    entryDate: DateTime.parse(json['entry_date']),
    value: json['value'] ?? 0,
    target: json['target'] ?? 1,
    isCompleted: json['is_completed'] ?? false,
    mood: json['mood'],
    note: json['note'],
    completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
  );

  double get progress => target > 0 ? (value / target).clamp(0.0, 1.0) : 0;
}

class PresetHabitModel {
  final String id;
  final String? categoryId;
  final String nameTr;
  final String nameEn;
  final String? descriptionTr;
  final String icon;
  final String color;
  final String defaultFrequency;
  final int defaultTargetCount;
  final String? defaultUnit;
  final bool isPopular;

  PresetHabitModel({
    required this.id,
    this.categoryId,
    required this.nameTr,
    required this.nameEn,
    this.descriptionTr,
    required this.icon,
    required this.color,
    this.defaultFrequency = 'daily',
    this.defaultTargetCount = 1,
    this.defaultUnit,
    this.isPopular = false,
  });

  factory PresetHabitModel.fromJson(Map<String, dynamic> json) => PresetHabitModel(
    id: json['id'],
    categoryId: json['category_id'],
    nameTr: json['name_tr'],
    nameEn: json['name_en'],
    descriptionTr: json['description_tr'],
    icon: json['icon'],
    color: json['color'],
    defaultFrequency: json['default_frequency'] ?? 'daily',
    defaultTargetCount: json['default_target_count'] ?? 1,
    defaultUnit: json['default_unit'],
    isPopular: json['is_popular'] ?? false,
  );
}
