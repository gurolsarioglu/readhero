import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/points_service.dart';

/// Reward Controller - Ödül yönetimi
class RewardController extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final PointsService _pointsService = PointsService();

  // State
  List<RewardModel> _rewards = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Öğrencinin ödüllerini yükle
  Future<void> loadRewards(String studentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await _db.query(
        'rewards',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'required_points ASC',
      );

      _rewards = results.map((map) => RewardModel.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Ödül yükleme hatası: $e');
    }
  }

  /// Yeni ödül ekle (Veli tarafından)
  Future<bool> addReward({
    required String studentId,
    required String title,
    required String description,
    required int requiredPoints,
    required String createdBy,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final reward = RewardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        title: title,
        description: description,
        requiredPoints: requiredPoints,
        isUnlocked: false,
        unlockedAt: null,
        isClaimed: false,
        claimedAt: null,
        createdBy: createdBy,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _db.insert('rewards', reward.toMap());

      // Listeyi yeniden yükle
      await loadRewards(studentId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Ödül ekleme hatası: $e');
      return false;
    }
  }

  /// Ödülü güncelle
  Future<bool> updateReward({
    required String rewardId,
    required String studentId,
    String? title,
    String? description,
    int? requiredPoints,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final rewardData = await _db.getById('rewards', rewardId);
      if (rewardData == null) {
        throw Exception('Ödül bulunamadı');
      }

      final reward = RewardModel.fromMap(rewardData);

      final updatedReward = RewardModel(
        id: reward.id,
        studentId: reward.studentId,
        title: title ?? reward.title,
        description: description ?? reward.description,
        requiredPoints: requiredPoints ?? reward.requiredPoints,
        isUnlocked: reward.isUnlocked,
        unlockedAt: reward.unlockedAt,
        isClaimed: reward.isClaimed,
        claimedAt: reward.claimedAt,
        createdBy: reward.createdBy,
        createdAt: reward.createdAt,
      );

      await _db.update('rewards', updatedReward.toMap(), rewardId);

      // Listeyi yeniden yükle
      await loadRewards(studentId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Ödül güncelleme hatası: $e');
      return false;
    }
  }

  /// Ödülü sil
  Future<bool> deleteReward(String rewardId, String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.delete('rewards', rewardId);

      // Listeyi yeniden yükle
      await loadRewards(studentId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Ödül silme hatası: $e');
      return false;
    }
  }

  /// Ödülü kilitle aç (puan yeterli olduğunda)
  Future<bool> unlockReward(String rewardId, String studentId) async {
    try {
      final rewardData = await _db.getById('rewards', rewardId);
      if (rewardData == null) {
        throw Exception('Ödül bulunamadı');
      }

      final reward = RewardModel.fromMap(rewardData);

      // Zaten açılmış mı?
      if (reward.isUnlocked) {
        return true;
      }

      // Puan yeterli mi?
      final currentPoints = await _pointsService.getCurrentPoints(studentId);
      if (currentPoints < reward.requiredPoints) {
        _errorMessage = 'Yetersiz puan';
        notifyListeners();
        return false;
      }

      // Ödülü aç
      final updatedReward = RewardModel(
        id: reward.id,
        studentId: reward.studentId,
        title: reward.title,
        description: reward.description,
        requiredPoints: reward.requiredPoints,
        isUnlocked: true,
        unlockedAt: DateTime.now().millisecondsSinceEpoch,
        isClaimed: reward.isClaimed,
        claimedAt: reward.claimedAt,
        createdBy: reward.createdBy,
        createdAt: reward.createdAt,
      );

      await _db.update('rewards', updatedReward.toMap(), rewardId);

      // Listeyi yeniden yükle
      await loadRewards(studentId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Ödül açma hatası: $e');
      return false;
    }
  }

  /// Ödülü talep et (puan harca)
  Future<bool> claimReward(String rewardId, String studentId) async {
    try {
      final rewardData = await _db.getById('rewards', rewardId);
      if (rewardData == null) {
        throw Exception('Ödül bulunamadı');
      }

      final reward = RewardModel.fromMap(rewardData);

      // Zaten talep edilmiş mi?
      if (reward.isClaimed) {
        _errorMessage = 'Ödül zaten talep edildi';
        notifyListeners();
        return false;
      }

      // Açılmış mı?
      if (!reward.isUnlocked) {
        _errorMessage = 'Ödül henüz açılmadı';
        notifyListeners();
        return false;
      }

      // Puanı düş
      final success = await _pointsService.deductPoints(
        studentId: studentId,
        points: reward.requiredPoints,
        reason: 'Ödül: ${reward.title}',
      );

      if (!success) {
        _errorMessage = 'Puan düşme hatası';
        notifyListeners();
        return false;
      }

      // Ödülü talep edildi olarak işaretle
      final updatedReward = RewardModel(
        id: reward.id,
        studentId: reward.studentId,
        title: reward.title,
        description: reward.description,
        requiredPoints: reward.requiredPoints,
        isUnlocked: reward.isUnlocked,
        unlockedAt: reward.unlockedAt,
        isClaimed: true,
        claimedAt: DateTime.now().millisecondsSinceEpoch,
        createdBy: reward.createdBy,
        createdAt: reward.createdAt,
      );

      await _db.update('rewards', updatedReward.toMap(), rewardId);

      // Listeyi yeniden yükle
      await loadRewards(studentId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Ödül talep etme hatası: $e');
      return false;
    }
  }

  /// Kilidi açılabilir ödülleri kontrol et
  Future<List<RewardModel>> checkUnlockableRewards(String studentId) async {
    try {
      final currentPoints = await _pointsService.getCurrentPoints(studentId);
      
      final unlockable = _rewards.where((reward) {
        return !reward.isUnlocked && 
               currentPoints >= reward.requiredPoints;
      }).toList();

      return unlockable;
    } catch (e) {
      debugPrint('Kilidi açılabilir ödül kontrolü hatası: $e');
      return [];
    }
  }

  /// Öğrencinin ödül istatistiklerini al
  Future<Map<String, int>> getRewardStats(String studentId) async {
    try {
      await loadRewards(studentId);

      final total = _rewards.length;
      final unlocked = _rewards.where((r) => r.isUnlocked).length;
      final claimed = _rewards.where((r) => r.isClaimed).length;
      final available = _rewards.where((r) => r.isUnlocked && !r.isClaimed).length;

      return {
        'total': total,
        'unlocked': unlocked,
        'claimed': claimed,
        'available': available,
      };
    } catch (e) {
      debugPrint('Ödül istatistikleri hatası: $e');
      return {
        'total': 0,
        'unlocked': 0,
        'claimed': 0,
        'available': 0,
      };
    }
  }

  /// Hatayı temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// State'i sıfırla
  void reset() {
    _rewards = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
