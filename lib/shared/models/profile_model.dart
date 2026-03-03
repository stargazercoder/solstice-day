class ProfileModel {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String timezone;
  final bool notificationEnabled;
  final int notificationHour;
  final int streakRecord;
  final int totalCompleted;
  final int level;
  final int xp;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.timezone = 'Europe/Istanbul',
    this.notificationEnabled = true,
    this.notificationHour = 9,
    this.streakRecord = 0,
    this.totalCompleted = 0,
    this.level = 1,
    this.xp = 0,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'],
    displayName: json['display_name'],
    avatarUrl: json['avatar_url'],
    bio: json['bio'],
    dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
    gender: json['gender'],
    timezone: json['timezone'] ?? 'Europe/Istanbul',
    notificationEnabled: json['notification_enabled'] ?? true,
    notificationHour: json['notification_hour'] ?? 9,
    streakRecord: json['streak_record'] ?? 0,
    totalCompleted: json['total_completed'] ?? 0,
    level: json['level'] ?? 1,
    xp: json['xp'] ?? 0,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'bio': bio,
    'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
    'gender': gender,
    'timezone': timezone,
    'notification_enabled': notificationEnabled,
    'notification_hour': notificationHour,
  };

  String get levelTitle {
    if (level < 5) return 'Çaylak';
    if (level < 10) return 'Amatör';
    if (level < 20) return 'Deneyimli';
    if (level < 35) return 'Uzman';
    if (level < 50) return 'Usta';
    return 'Efsane';
  }
}
