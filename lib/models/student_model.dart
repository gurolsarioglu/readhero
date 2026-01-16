import 'dart:convert';

/// Öğrenci modeli
class StudentModel {
  final String id;
  final String userId;
  final String name;
  final int gradeLevel; // 1-4
  final String avatar;
  final int currentPoints;
  final int totalPoints;
  final List<String> badges;
  final int dailyGoal; // dakika
  final int weeklyGoal; // kitap sayısı
  final int createdAt;
  final int updatedAt;

  StudentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.gradeLevel,
    this.avatar = 'default',
    this.currentPoints = 0,
    this.totalPoints = 0,
    this.badges = const [],
    this.dailyGoal = 20,
    this.weeklyGoal = 5,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(gradeLevel >= 1 && gradeLevel <= 4, 'Grade level must be between 1 and 4');

  /// JSON'dan model oluştur
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gradeLevel: json['grade_level'] as int,
      avatar: json['avatar'] as String? ?? 'default',
      currentPoints: json['current_points'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      badges: _parseBadges(json['badges']),
      dailyGoal: json['daily_goal'] as int? ?? 20,
      weeklyGoal: json['weekly_goal'] as int? ?? 5,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  /// Badges JSON string'ini List'e çevir
  static List<String> _parseBadges(dynamic badgesData) {
    if (badgesData == null) return [];
    if (badgesData is String) {
      try {
        final List<dynamic> decoded = jsonDecode(badgesData);
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    if (badgesData is List) {
      return badgesData.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'grade_level': gradeLevel,
      'avatar': avatar,
      'current_points': currentPoints,
      'total_points': totalPoints,
      'badges': jsonEncode(badges),
      'daily_goal': dailyGoal,
      'weekly_goal': weeklyGoal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Database Map'ten model oluştur
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel.fromJson(map);
  }

  /// Model'i Database Map'e çevir
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Kopya oluştur
  StudentModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? gradeLevel,
    String? avatar,
    int? currentPoints,
    int? totalPoints,
    List<String>? badges,
    int? dailyGoal,
    int? weeklyGoal,
    int? createdAt,
    int? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      avatar: avatar ?? this.avatar,
      currentPoints: currentPoints ?? this.currentPoints,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Puan ekle
  StudentModel addPoints(int points) {
    return copyWith(
      currentPoints: currentPoints + points,
      totalPoints: totalPoints + points,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Puan harca
  StudentModel spendPoints(int points) {
    final newPoints = currentPoints - points;
    if (newPoints < 0) {
      throw Exception('Insufficient points');
    }
    return copyWith(
      currentPoints: newPoints,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Rozet ekle
  StudentModel addBadge(String badgeId) {
    if (badges.contains(badgeId)) {
      return this;
    }
    return copyWith(
      badges: [...badges, badgeId],
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Öğrenme modu mu? (1. sınıf)
  bool get isLearningMode => gradeLevel == 1;

  /// Hız modu mu? (2-4. sınıf)
  bool get isSpeedMode => gradeLevel > 1;

  @override
  String toString() {
    return 'StudentModel(id: $id, name: $name, grade: $gradeLevel, points: $currentPoints)';
  }
}
