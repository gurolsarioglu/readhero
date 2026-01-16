import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

/// Points Service - Puan hesaplama ve yönetim servisi
/// 
/// Puan Dağılımı:
/// - Okuma tamamlama: 20 puan (sabit)
/// - Okuma hızı bonusu: 0-20 puan (WPM'e göre)
/// - Sınav başarısı: 0-60 puan (skor'a göre)
/// - Göz molası: 5 puan (her mola için)
/// - Günlük hedef: 10 puan
/// - Haftalık hedef: 50 puan
class PointsService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ==================== PUAN HESAPLAMA ====================

  /// Okuma puanı hesapla (toplam 40 puan)
  /// - Tamamlama: 20 puan
  /// - Hız bonusu: 0-20 puan (WPM'e göre)
  int calculateReadingPoints({
    required int gradeLevel,
    required double wpm,
    required bool isCompleted,
  }) {
    if (!isCompleted) return 0;

    int points = 20; // Tamamlama puanı

    // WPM hedefleri (sınıf seviyesine göre)
    final wpmTargets = {
      1: 40,  // 1. sınıf: 40 WPM
      2: 60,  // 2. sınıf: 60 WPM
      3: 80,  // 3. sınıf: 80 WPM
      4: 100, // 4. sınıf: 100 WPM
    };

    final targetWpm = wpmTargets[gradeLevel] ?? 60;
    
    // WPM bonusu hesapla (0-20 puan)
    if (wpm >= targetWpm * 1.5) {
      points += 20; // Mükemmel hız
    } else if (wpm >= targetWpm * 1.2) {
      points += 15; // Çok iyi hız
    } else if (wpm >= targetWpm) {
      points += 10; // İyi hız
    } else if (wpm >= targetWpm * 0.8) {
      points += 5; // Orta hız
    }

    return points;
  }

  /// Sınav puanı hesapla (0-60 puan)
  int calculateQuizPoints({
    required int score, // 0-100 arası
  }) {
    // Skor'u 60 puana çevir
    return ((score / 100) * 60).round();
  }

  /// Göz molası puanı
  int getEyeBreakPoints() {
    return 5;
  }

  /// Günlük hedef puanı
  int getDailyGoalPoints() {
    return 10;
  }

  /// Haftalık hedef puanı
  int getWeeklyGoalPoints() {
    return 50;
  }

  /// Toplam oturum puanı hesapla (okuma + sınav)
  int calculateSessionTotalPoints({
    required int gradeLevel,
    required double wpm,
    required bool isCompleted,
    required int quizScore,
  }) {
    final readingPoints = calculateReadingPoints(
      gradeLevel: gradeLevel,
      wpm: wpm,
      isCompleted: isCompleted,
    );

    final quizPoints = calculateQuizPoints(score: quizScore);

    return readingPoints + quizPoints;
  }

  // ==================== PUAN YÖNETİMİ ====================

  /// Öğrenciye puan ekle
  Future<void> addPoints({
    required String studentId,
    required int points,
    String? reason,
  }) async {
    try {
      // Öğrenciyi al
      final studentData = await _db.getById('students', studentId);
      if (studentData == null) {
        throw Exception('Öğrenci bulunamadı');
      }

      final student = StudentModel.fromMap(studentData);

      // Puanları güncelle
      final updatedStudent = StudentModel(
        id: student.id,
        userId: student.userId,
        name: student.name,
        gradeLevel: student.gradeLevel,
        avatar: student.avatar,
        currentPoints: student.currentPoints + points,
        totalPoints: student.totalPoints + points,
        badges: student.badges,
        dailyGoal: student.dailyGoal,
        weeklyGoal: student.weeklyGoal,
        createdAt: student.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Veritabanına kaydet
      await _db.update('students', updatedStudent.toMap(), studentId);

      debugPrint('✅ $points puan eklendi: ${student.name} (Sebep: ${reason ?? "Belirtilmedi"})');
    } catch (e) {
      debugPrint('❌ Puan ekleme hatası: $e');
      rethrow;
    }
  }

  /// Öğrenciden puan düş (ödül kullanımı için)
  Future<bool> deductPoints({
    required String studentId,
    required int points,
    String? reason,
  }) async {
    try {
      // Öğrenciyi al
      final studentData = await _db.getById('students', studentId);
      if (studentData == null) {
        throw Exception('Öğrenci bulunamadı');
      }

      final student = StudentModel.fromMap(studentData);

      // Yeterli puan var mı kontrol et
      if (student.currentPoints < points) {
        debugPrint('⚠️ Yetersiz puan: ${student.currentPoints} < $points');
        return false;
      }

      // Puanları güncelle
      final updatedStudent = StudentModel(
        id: student.id,
        userId: student.userId,
        name: student.name,
        gradeLevel: student.gradeLevel,
        avatar: student.avatar,
        currentPoints: student.currentPoints - points,
        totalPoints: student.totalPoints, // Toplam puan değişmez
        badges: student.badges,
        dailyGoal: student.dailyGoal,
        weeklyGoal: student.weeklyGoal,
        createdAt: student.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Veritabanına kaydet
      await _db.update('students', updatedStudent.toMap(), studentId);

      debugPrint('✅ $points puan harcandı: ${student.name} (Sebep: ${reason ?? "Belirtilmedi"})');
      return true;
    } catch (e) {
      debugPrint('❌ Puan düşme hatası: $e');
      return false;
    }
  }

  /// Öğrencinin mevcut puanını al
  Future<int> getCurrentPoints(String studentId) async {
    try {
      final studentData = await _db.getById('students', studentId);
      if (studentData == null) return 0;

      final student = StudentModel.fromMap(studentData);
      return student.currentPoints;
    } catch (e) {
      debugPrint('❌ Puan alma hatası: $e');
      return 0;
    }
  }

  /// Öğrencinin toplam puanını al
  Future<int> getTotalPoints(String studentId) async {
    try {
      final studentData = await _db.getById('students', studentId);
      if (studentData == null) return 0;

      final student = StudentModel.fromMap(studentData);
      return student.totalPoints;
    } catch (e) {
      debugPrint('❌ Toplam puan alma hatası: $e');
      return 0;
    }
  }

  // ==================== ROZET SİSTEMİ ====================

  /// Rozet kazanma kontrolü
  Future<List<String>> checkAndAwardBadges(String studentId) async {
    try {
      final newBadges = <String>[];

      // Öğrenciyi al
      final studentData = await _db.getById('students', studentId);
      if (studentData == null) return newBadges;

      final student = StudentModel.fromMap(studentData);

      // İstatistikleri al
      final stats = await _getStudentStats(studentId);

      // Rozet kontrolleri
      final badgeChecks = {
        'first_book': stats['booksRead'] >= 1,
        'book_worm': stats['booksRead'] >= 10,
        'speed_reader': stats['avgWpm'] >= 100,
        'perfect_score': stats['perfectQuizzes'] >= 5,
        'week_streak': stats['currentStreak'] >= 7,
        'point_master': student.totalPoints >= 1000,
        'quiz_master': stats['quizzesPassed'] >= 20,
        'reading_champion': stats['booksRead'] >= 50,
      };

      // Yeni rozetleri kontrol et
      for (final entry in badgeChecks.entries) {
        final badgeId = entry.key;
        final earned = entry.value;

        if (earned && !student.badges.contains(badgeId)) {
          newBadges.add(badgeId);
        }
      }

      // Yeni rozetleri ekle
      if (newBadges.isNotEmpty) {
        final updatedBadges = [...student.badges, ...newBadges];
        final updatedStudent = StudentModel(
          id: student.id,
          userId: student.userId,
          name: student.name,
          gradeLevel: student.gradeLevel,
          avatar: student.avatar,
          currentPoints: student.currentPoints,
          totalPoints: student.totalPoints,
          badges: updatedBadges,
          dailyGoal: student.dailyGoal,
          weeklyGoal: student.weeklyGoal,
          createdAt: student.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        await _db.update('students', updatedStudent.toMap(), studentId);
        debugPrint('🏆 Yeni rozetler kazanıldı: $newBadges');
      }

      return newBadges;
    } catch (e) {
      debugPrint('❌ Rozet kontrolü hatası: $e');
      return [];
    }
  }

  /// Öğrenci istatistiklerini al
  Future<Map<String, dynamic>> _getStudentStats(String studentId) async {
    try {
      // Okuma oturumları
      final sessions = await _db.query(
        'reading_sessions',
        where: 'student_id = ? AND is_completed = 1',
        whereArgs: [studentId],
      );

      // Quiz sonuçları
      final quizResults = await _db.rawQuery('''
        SELECT qr.* FROM quiz_results qr
        INNER JOIN reading_sessions rs ON qr.session_id = rs.id
        WHERE rs.student_id = ?
      ''', [studentId]);

      // İstatistikleri hesapla
      final booksRead = sessions.length;
      final avgWpm = sessions.isEmpty
          ? 0
          : sessions.map((s) => s['wpm'] as double).reduce((a, b) => a + b) / sessions.length;
      
      final perfectQuizzes = quizResults.where((q) => q['score'] == 100).length;
      final quizzesPassed = quizResults.where((q) => (q['score'] as num).toInt() >= 60).length;

      // Streak hesapla (basit versiyon)
      final currentStreak = await _calculateStreak(studentId);

      return {
        'booksRead': booksRead,
        'avgWpm': avgWpm.round(),
        'perfectQuizzes': perfectQuizzes,
        'quizzesPassed': quizzesPassed,
        'currentStreak': currentStreak,
      };
    } catch (e) {
      debugPrint('❌ İstatistik alma hatası: $e');
      return {
        'booksRead': 0,
        'avgWpm': 0,
        'perfectQuizzes': 0,
        'quizzesPassed': 0,
        'currentStreak': 0,
      };
    }
  }

  /// Günlük streak hesapla
  Future<int> _calculateStreak(String studentId) async {
    try {
      final sessions = await _db.query(
        'reading_sessions',
        where: 'student_id = ? AND is_completed = 1',
        whereArgs: [studentId],
        orderBy: 'created_at DESC',
      );

      if (sessions.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final session in sessions) {
        final sessionDate = DateTime.fromMillisecondsSinceEpoch(session['created_at'] as int);
        final dateOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

        if (lastDate == null) {
          lastDate = dateOnly;
          streak = 1;
        } else {
          final diff = lastDate.difference(dateOnly).inDays;
          if (diff == 1) {
            streak++;
            lastDate = dateOnly;
          } else if (diff > 1) {
            break; // Streak kırıldı
          }
        }
      }

      return streak;
    } catch (e) {
      debugPrint('❌ Streak hesaplama hatası: $e');
      return 0;
    }
  }

  // ==================== ROZET BİLGİLERİ ====================

  /// Rozet bilgilerini al
  Map<String, dynamic> getBadgeInfo(String badgeId) {
    final badges = {
      'first_book': {
        'name': 'İlk Kitap',
        'description': 'İlk kitabını tamamladın!',
        'icon': '📖',
        'color': 0xFFFFD166,
      },
      'book_worm': {
        'name': 'Kitap Kurdu',
        'description': '10 kitap okudun!',
        'icon': '📚',
        'color': 0xFF88D498,
      },
      'speed_reader': {
        'name': 'Hızlı Okuyucu',
        'description': '100+ WPM hıza ulaştın!',
        'icon': '🏃',
        'color': 0xFFFF8C42,
      },
      'perfect_score': {
        'name': 'Tam İsabet',
        'description': '5 sınavdan tam puan aldın!',
        'icon': '🎯',
        'color': 0xFFEF476F,
      },
      'week_streak': {
        'name': '7 Gün Streak',
        'description': '7 gün üst üste okudun!',
        'icon': '🔥',
        'color': 0xFFFF6B6B,
      },
      'point_master': {
        'name': 'Puan Ustası',
        'description': '1000 puan topladın!',
        'icon': '⭐',
        'color': 0xFFFFD700,
      },
      'quiz_master': {
        'name': 'Sınav Şampiyonu',
        'description': '20 sınavı geçtin!',
        'icon': '🏆',
        'color': 0xFF4ECDC4,
      },
      'reading_champion': {
        'name': 'Okuma Şampiyonu',
        'description': '50 kitap okudun!',
        'icon': '👑',
        'color': 0xFFFFD700,
      },
    };

    return badges[badgeId] ?? {
      'name': 'Bilinmeyen Rozet',
      'description': '',
      'icon': '❓',
      'color': 0xFF999999,
    };
  }

  /// Tüm rozetleri al
  List<String> getAllBadgeIds() {
    return [
      'first_book',
      'book_worm',
      'speed_reader',
      'perfect_score',
      'week_streak',
      'point_master',
      'quiz_master',
      'reading_champion',
    ];
  }
}
