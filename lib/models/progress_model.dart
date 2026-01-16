/// İlerleme (Progress) modeli
class ProgressModel {
  final String id;
  final String studentId;
  final int date; // Gün başı timestamp
  final int dailyReadingTime; // Dakika
  final int dailyBooksCompleted;
  final int dailyPointsEarned;
  final bool dailyGoalAchieved;
  final int weeklyBooksCompleted;
  final bool weeklyGoalAchieved;
  final int createdAt;
  final int updatedAt;

  ProgressModel({
    required this.id,
    required this.studentId,
    required this.date,
    this.dailyReadingTime = 0,
    this.dailyBooksCompleted = 0,
    this.dailyPointsEarned = 0,
    this.dailyGoalAchieved = false,
    this.weeklyBooksCompleted = 0,
    this.weeklyGoalAchieved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan model oluştur
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      date: json['date'] as int,
      dailyReadingTime: json['daily_reading_time'] as int? ?? 0,
      dailyBooksCompleted: json['daily_books_completed'] as int? ?? 0,
      dailyPointsEarned: json['daily_points_earned'] as int? ?? 0,
      dailyGoalAchieved: (json['daily_goal_achieved'] as int?) == 1,
      weeklyBooksCompleted: json['weekly_books_completed'] as int? ?? 0,
      weeklyGoalAchieved: (json['weekly_goal_achieved'] as int?) == 1,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date,
      'daily_reading_time': dailyReadingTime,
      'daily_books_completed': dailyBooksCompleted,
      'daily_points_earned': dailyPointsEarned,
      'daily_goal_achieved': dailyGoalAchieved ? 1 : 0,
      'weekly_books_completed': weeklyBooksCompleted,
      'weekly_goal_achieved': weeklyGoalAchieved ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Database Map'ten model oluştur
  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel.fromJson(map);
  }

  /// Model'i Database Map'e çevir
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Kopya oluştur
  ProgressModel copyWith({
    String? id,
    String? studentId,
    int? date,
    int? dailyReadingTime,
    int? dailyBooksCompleted,
    int? dailyPointsEarned,
    bool? dailyGoalAchieved,
    int? weeklyBooksCompleted,
    bool? weeklyGoalAchieved,
    int? createdAt,
    int? updatedAt,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      dailyReadingTime: dailyReadingTime ?? this.dailyReadingTime,
      dailyBooksCompleted: dailyBooksCompleted ?? this.dailyBooksCompleted,
      dailyPointsEarned: dailyPointsEarned ?? this.dailyPointsEarned,
      dailyGoalAchieved: dailyGoalAchieved ?? this.dailyGoalAchieved,
      weeklyBooksCompleted: weeklyBooksCompleted ?? this.weeklyBooksCompleted,
      weeklyGoalAchieved: weeklyGoalAchieved ?? this.weeklyGoalAchieved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Okuma süresi ekle (dakika)
  ProgressModel addReadingTime(int minutes) {
    return copyWith(
      dailyReadingTime: dailyReadingTime + minutes,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Kitap ekle
  ProgressModel addBook() {
    return copyWith(
      dailyBooksCompleted: dailyBooksCompleted + 1,
      weeklyBooksCompleted: weeklyBooksCompleted + 1,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Puan ekle
  ProgressModel addPoints(int points) {
    return copyWith(
      dailyPointsEarned: dailyPointsEarned + points,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Günlük hedef kontrolü
  ProgressModel checkDailyGoal(int goalMinutes) {
    final achieved = dailyReadingTime >= goalMinutes;
    return copyWith(
      dailyGoalAchieved: achieved,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Haftalık hedef kontrolü
  ProgressModel checkWeeklyGoal(int goalBooks) {
    final achieved = weeklyBooksCompleted >= goalBooks;
    return copyWith(
      weeklyGoalAchieved: achieved,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Tarih formatı (GG/AA/YYYY)
  String get formattedDate {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  String toString() {
    return 'ProgressModel(id: $id, date: $formattedDate, books: $dailyBooksCompleted, time: ${dailyReadingTime}m)';
  }
}
