import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../database/database_helper.dart';
import '../services/points_service.dart';

/// Hedef yönetim servisi
class GoalService {
  static final GoalService instance = GoalService._init();
  GoalService._init();

  final _uuid = const Uuid();
  final _db = DatabaseHelper.instance;

  // ==================== HEDEF OLUŞTURMA ====================

  /// Varsayılan günlük hedefleri oluştur
  Future<List<GoalModel>> createDefaultDailyGoals(String studentId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final goals = [
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.daily,
        category: GoalCategory.readingTime,
        targetValue: 20, // 20 dakika
        startDate: startOfDay,
        endDate: endOfDay,
        rewardPoints: 10,
      ),
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.daily,
        category: GoalCategory.booksCompleted,
        targetValue: 1, // 1 kitap
        startDate: startOfDay,
        endDate: endOfDay,
        rewardPoints: 15,
      ),
    ];

    for (var goal in goals) {
      await _saveGoal(goal);
    }

    return goals;
  }

  /// Varsayılan haftalık hedefleri oluştur
  Future<List<GoalModel>> createDefaultWeeklyGoals(String studentId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    final goals = [
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.weekly,
        category: GoalCategory.booksCompleted,
        targetValue: 5, // 5 kitap
        startDate: startDate,
        endDate: endDate,
        rewardPoints: 50,
      ),
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.weekly,
        category: GoalCategory.quizzesPassed,
        targetValue: 5, // 5 sınav
        startDate: startDate,
        endDate: endDate,
        rewardPoints: 40,
      ),
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.weekly,
        category: GoalCategory.streak,
        targetValue: 5, // 5 gün üst üste
        startDate: startDate,
        endDate: endDate,
        rewardPoints: 60,
      ),
    ];

    for (var goal in goals) {
      await _saveGoal(goal);
    }

    return goals;
  }

  /// Varsayılan aylık hedefleri oluştur
  Future<List<GoalModel>> createDefaultMonthlyGoals(String studentId) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 1);

    final goals = [
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.monthly,
        category: GoalCategory.booksCompleted,
        targetValue: 20, // 20 kitap
        startDate: startDate,
        endDate: endDate,
        rewardPoints: 200,
      ),
      GoalModel(
        id: _uuid.v4(),
        studentId: studentId,
        type: GoalType.monthly,
        category: GoalCategory.perfectScores,
        targetValue: 10, // 10 mükemmel sınav
        startDate: startDate,
        endDate: endDate,
        rewardPoints: 150,
      ),
    ];

    for (var goal in goals) {
      await _saveGoal(goal);
    }

    return goals;
  }

  // ==================== HEDEF GÜNCELLEME ====================

  /// Okuma süresi hedefini güncelle
  Future<void> updateReadingTimeGoal(String studentId, int minutes) async {
    final goals = await getActiveGoalsByCategory(studentId, GoalCategory.readingTime);
    
    for (var goal in goals) {
      final updatedGoal = goal.copyWith(
        currentValue: goal.currentValue + minutes,
      );
      await _updateGoal(updatedGoal);
      await _checkGoalCompletion(updatedGoal);
    }
  }

  /// Kitap tamamlama hedefini güncelle
  Future<void> updateBooksCompletedGoal(String studentId) async {
    final goals = await getActiveGoalsByCategory(studentId, GoalCategory.booksCompleted);
    
    for (var goal in goals) {
      final updatedGoal = goal.copyWith(
        currentValue: goal.currentValue + 1,
      );
      await _updateGoal(updatedGoal);
      await _checkGoalCompletion(updatedGoal);
    }
  }

  /// Sınav geçme hedefini güncelle
  Future<void> updateQuizzesPassedGoal(String studentId) async {
    final goals = await getActiveGoalsByCategory(studentId, GoalCategory.quizzesPassed);
    
    for (var goal in goals) {
      final updatedGoal = goal.copyWith(
        currentValue: goal.currentValue + 1,
      );
      await _updateGoal(updatedGoal);
      await _checkGoalCompletion(updatedGoal);
    }
  }

  /// Mükemmel sınav hedefini güncelle
  Future<void> updatePerfectScoresGoal(String studentId) async {
    final goals = await getActiveGoalsByCategory(studentId, GoalCategory.perfectScores);
    
    for (var goal in goals) {
      final updatedGoal = goal.copyWith(
        currentValue: goal.currentValue + 1,
      );
      await _updateGoal(updatedGoal);
      await _checkGoalCompletion(updatedGoal);
    }
  }

  /// Streak hedefini güncelle
  Future<void> updateStreakGoal(String studentId, int currentStreak) async {
    final goals = await getActiveGoalsByCategory(studentId, GoalCategory.streak);
    
    for (var goal in goals) {
      final updatedGoal = goal.copyWith(
        currentValue: currentStreak,
      );
      await _updateGoal(updatedGoal);
      await _checkGoalCompletion(updatedGoal);
    }
  }

  // ==================== HEDEF SORGULAMA ====================

  /// Öğrencinin aktif hedeflerini getir
  Future<List<GoalModel>> getActiveGoals(String studentId) async {
    final results = await _db.rawQuery('''
      SELECT * FROM goals
      WHERE student_id = ? 
        AND is_completed = 0
        AND end_date > ?
      ORDER BY end_date ASC
    ''', [studentId, DateTime.now().millisecondsSinceEpoch]);

    return results.map((map) => GoalModel.fromMap(map)).toList();
  }

  /// Kategoriye göre aktif hedefleri getir
  Future<List<GoalModel>> getActiveGoalsByCategory(
    String studentId,
    GoalCategory category,
  ) async {
    final results = await _db.rawQuery('''
      SELECT * FROM goals
      WHERE student_id = ? 
        AND category = ?
        AND is_completed = 0
        AND end_date > ?
    ''', [studentId, category.index, DateTime.now().millisecondsSinceEpoch]);

    return results.map((map) => GoalModel.fromMap(map)).toList();
  }

  /// Türe göre aktif hedefleri getir
  Future<List<GoalModel>> getActiveGoalsByType(
    String studentId,
    GoalType type,
  ) async {
    final results = await _db.rawQuery('''
      SELECT * FROM goals
      WHERE student_id = ? 
        AND type = ?
        AND is_completed = 0
        AND end_date > ?
    ''', [studentId, type.index, DateTime.now().millisecondsSinceEpoch]);

    return results.map((map) => GoalModel.fromMap(map)).toList();
  }

  /// Tamamlanmış hedefleri getir
  Future<List<GoalModel>> getCompletedGoals(String studentId) async {
    final results = await _db.rawQuery('''
      SELECT * FROM goals
      WHERE student_id = ? 
        AND is_completed = 1
      ORDER BY completed_at DESC
      LIMIT 20
    ''', [studentId]);

    return results.map((map) => GoalModel.fromMap(map)).toList();
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Hedefi kaydet
  Future<void> _saveGoal(GoalModel goal) async {
    await _db.insert('goals', goal.toMap());
  }

  /// Hedefi güncelle
  Future<void> _updateGoal(GoalModel goal) async {
    await _db.update('goals', goal.toMap(), goal.id);
  }

  /// Hedef tamamlanma kontrolü
  Future<void> _checkGoalCompletion(GoalModel goal) async {
    if (goal.isAchieved && !goal.isCompleted) {
      final completedGoal = goal.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _updateGoal(completedGoal);
      
      // Ödül puanını ver
      try {
        await PointsService().addPoints(
          studentId: goal.studentId,
          points: goal.rewardPoints,
          reason: 'Hedef tamamlandı: ${goal.category.name}',
        );
      } catch (e) {
        // Puan ekleme hatası hedef durumunu etkilemez
      }
    }
  }

  /// Süresi dolmuş hedefleri temizle
  Future<void> cleanupExpiredGoals(String studentId) async {
    await _db.rawQuery('''
      DELETE FROM goals
      WHERE student_id = ? 
        AND is_completed = 0
        AND end_date < ?
    ''', [studentId, DateTime.now().millisecondsSinceEpoch]);
  }

  /// Tüm hedefleri sil (test için)
  Future<void> deleteAllGoals(String studentId) async {
    await _db.rawQuery('''
      DELETE FROM goals WHERE student_id = ?
    ''', [studentId]);
  }
}
