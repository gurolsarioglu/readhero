import 'package:flutter/material.dart';

/// Hedef türleri
enum GoalType {
  daily,   // Günlük
  weekly,  // Haftalık
  monthly, // Aylık
}

/// Hedef kategorileri
enum GoalCategory {
  readingTime,    // Okuma süresi (dakika)
  booksCompleted, // Tamamlanan kitap sayısı
  quizzesPassed,  // Başarılan sınav sayısı
  perfectScores,  // Mükemmel sınav sayısı
  streak,         // Ardışık gün sayısı
}

/// Hedef modeli
class GoalModel {
  final String id;
  final String studentId;
  final GoalType type;
  final GoalCategory category;
  final int targetValue;
  final int currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardPoints;

  GoalModel({
    this.id = '',
    this.studentId = '',
    this.type = GoalType.daily,
    this.category = GoalCategory.readingTime,
    this.targetValue = 0,
    this.currentValue = 0,
    DateTime? startDate,
    DateTime? endDate,
    this.isCompleted = false,
    this.completedAt,
    this.rewardPoints = 0,
  }) : this.startDate = startDate ?? DateTime.now(),
       this.endDate = endDate ?? DateTime.now().add(const Duration(days: 1));

  /// Progress yüzdesi (0.0 - 1.0)
  double get progress {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Progress yüzdesi (0-100)
  int get progressPercentage {
    return (progress * 100).toInt();
  }

  /// Kalan değer
  int get remainingValue {
    return (targetValue - currentValue).clamp(0, targetValue);
  }

  /// Hedef tamamlandı mı?
  bool get isAchieved {
    return currentValue >= targetValue;
  }

  /// Hedef süresi doldu mu?
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Hedef aktif mi?
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isCompleted;
  }

  /// Hedef türü adı
  String get typeName {
    switch (type) {
      case GoalType.daily:
        return 'Günlük';
      case GoalType.weekly:
        return 'Haftalık';
      case GoalType.monthly:
        return 'Aylık';
    }
  }

  /// Hedef kategori adı
  String get categoryName {
    switch (category) {
      case GoalCategory.readingTime:
        return 'Okuma Süresi';
      case GoalCategory.booksCompleted:
        return 'Kitap Tamamlama';
      case GoalCategory.quizzesPassed:
        return 'Sınav Başarısı';
      case GoalCategory.perfectScores:
        return 'Mükemmel Sınav';
      case GoalCategory.streak:
        return 'Ardışık Gün';
    }
  }

  /// Hedef açıklaması
  String get description {
    switch (category) {
      case GoalCategory.readingTime:
        return '$targetValue dakika oku';
      case GoalCategory.booksCompleted:
        return '$targetValue kitap tamamla';
      case GoalCategory.quizzesPassed:
        return '$targetValue sınav geç';
      case GoalCategory.perfectScores:
        return '$targetValue mükemmel sınav';
      case GoalCategory.streak:
        return '$targetValue gün üst üste oku';
    }
  }

  /// Hedef ikonu
  IconData get icon {
    switch (category) {
      case GoalCategory.readingTime:
        return Icons.timer_outlined;
      case GoalCategory.booksCompleted:
        return Icons.book_outlined;
      case GoalCategory.quizzesPassed:
        return Icons.check_circle_outline;
      case GoalCategory.perfectScores:
        return Icons.stars_outlined;
      case GoalCategory.streak:
        return Icons.local_fire_department_outlined;
    }
  }

  /// Hedef rengi
  Color get color {
    switch (category) {
      case GoalCategory.readingTime:
        return Colors.blue;
      case GoalCategory.booksCompleted:
        return Colors.green;
      case GoalCategory.quizzesPassed:
        return Colors.orange;
      case GoalCategory.perfectScores:
        return Colors.purple;
      case GoalCategory.streak:
        return Colors.red;
    }
  }

  /// Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'type': type.index,
      'category': category.index,
      'target_value': targetValue,
      'current_value': currentValue,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'reward_points': rewardPoints,
    };
  }

  /// Map'ten oluştur
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      type: GoalType.values[map['type'] ?? 0],
      category: GoalCategory.values[map['category'] ?? 0],
      targetValue: map['target_value'] ?? 0,
      currentValue: map['current_value'] ?? 0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] ?? DateTime.now().millisecondsSinceEpoch),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] ?? DateTime.now().millisecondsSinceEpoch),
      isCompleted: map['is_completed'] == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      rewardPoints: map['reward_points'] ?? 0,
    );
  }

  /// Kopyala
  GoalModel copyWith({
    String? id,
    String? studentId,
    GoalType? type,
    GoalCategory? category,
    int? targetValue,
    int? currentValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? rewardPoints,
  }) {
    return GoalModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}
