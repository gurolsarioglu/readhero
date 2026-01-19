import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/eye_break_service.dart';
import '../services/points_service.dart';
import '../services/goal_service.dart';

/// Okuma controller - Okuma oturumu yönetimi
class ReadingController extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final EyeBreakService _eyeBreakService = EyeBreakService();
  final PointsService _pointsService = PointsService();

  // ==================== STATE ====================

  StoryModel? _currentStory;
  StudentModel? _currentStudent;
  ReadingSessionModel? _currentSession;
  
  bool _isReading = false;
  bool _isPaused = false;
  
  // Zamanlayıcı
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  // WPM hesaplama
  int _wordsPerMinute = 0;
  
  // İlerleme
  double _progress = 0.0;
  
  String? _errorMessage;

  // ==================== GETTERS ====================

  /// Mevcut hikaye
  StoryModel? get currentStory => _currentStory;

  /// Mevcut öğrenci
  StudentModel? get currentStudent => _currentStudent;

  /// Mevcut oturum
  ReadingSessionModel? get currentSession => _currentSession;

  /// Okuma durumu
  bool get isReading => _isReading;

  /// Duraklatıldı mı?
  bool get isPaused => _isPaused;

  /// Geçen süre (saniye)
  int get elapsedSeconds => _elapsedSeconds;

  /// Geçen süre (dakika:saniye formatı)
  String get formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// WPM (Words Per Minute)
  int get wordsPerMinute => _wordsPerMinute;

  /// İlerleme yüzdesi
  double get progress => _progress;

  /// Hata mesajı
  String? get errorMessage => _errorMessage;

  /// Okuma aktif mi? (başlatıldı ve duraklatılmadı)
  bool get isActiveReading => _isReading && !_isPaused;

  // ==================== OKUMA YÖNETİMİ ====================

  /// Okumayı başlat
  void startReading({
    required StoryModel story,
    required StudentModel student,
  }) {
    _currentStory = story;
    _currentStudent = student;
    _isReading = true;
    _isPaused = false;
    _elapsedSeconds = 0;
    _progress = 0.0;
    _wordsPerMinute = 0;
    _clearError();

    // Timer'ı başlat
    _startTimer();
    
    notifyListeners();
  }

  /// Okumayı duraklat
  void pauseReading() {
    if (!_isReading) return;
    
    _isPaused = true;
    _stopTimer();
    _calculateWPM();
    
    notifyListeners();
  }

  /// Okumayı devam ettir
  void resumeReading() {
    if (!_isReading || !_isPaused) return;
    
    _isPaused = false;
    _startTimer();
    
    notifyListeners();
  }

  /// Okumayı bitir
  Future<bool> finishReading() async {
    if (!_isReading || _currentStory == null || _currentStudent == null) {
      return false;
    }

    try {
      _stopTimer();
      _calculateWPM();
      
      // Okuma oturumunu kaydet (ÖNCE KAYDET!)
      await _saveReadingSession();
      
      // Hedefleri güncelle
      try {
        final goalService = GoalService.instance;
        await goalService.updateReadingTimeGoal(_currentStudent!.id, _elapsedSeconds ~/ 60);
        await goalService.updateBooksCompletedGoal(_currentStudent!.id);
      } catch (e) {
        debugPrint('⚠️ Hedef güncelleme hatası: $e');
      }

      // NOT: State'i HEMEN TEMİZLEME! Quiz için session'a ihtiyacımız var
      // _resetState() reading_view.dart'da quiz navigation'dan sonra çağrılacak
      
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Okumayı iptal et
  void cancelReading() {
    _stopTimer();
    _resetState();
  }

  // ==================== TIMER YÖNETİMİ ====================

  /// Timer'ı başlat
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _calculateWPM();
      notifyListeners();
    });
  }

  /// Timer'ı durdur
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ==================== WPM HESAPLAMA ====================

  /// WPM (Words Per Minute) hesapla
  void _calculateWPM() {
    if (_currentStory == null || _elapsedSeconds == 0) {
      _wordsPerMinute = 0;
      return;
    }

    // WPM = (Kelime Sayısı / Geçen Süre (saniye)) * 60
    final wordCount = _currentStory!.wordCount;
    _wordsPerMinute = ((wordCount / _elapsedSeconds) * 60).round();
  }

  /// Tahmini kalan süre (saniye)
  int get estimatedRemainingSeconds {
    if (_currentStory == null || _wordsPerMinute == 0) {
      return 0;
    }

    final totalWords = _currentStory!.wordCount;
    final readWords = (_wordsPerMinute * _elapsedSeconds) ~/ 60;
    final remainingWords = totalWords - readWords;
    
    if (remainingWords <= 0) return 0;
    
    return ((remainingWords / _wordsPerMinute) * 60).round();
  }

  /// Tahmini kalan süre (formatlanmış)
  String get formattedRemainingTime {
    final seconds = estimatedRemainingSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ==================== İLERLEME TAKİBİ ====================

  /// İlerlemeyi güncelle (scroll pozisyonuna göre)
  void updateProgress(double scrollProgress) {
    _progress = scrollProgress.clamp(0.0, 1.0);
    notifyListeners();
  }

  // ==================== VERİTABANI İŞLEMLERİ ====================

  /// Okuma oturumunu kaydet
  Future<void> _saveReadingSession() async {
    if (_currentStory == null || _currentStudent == null) {
      throw Exception('Hikaye veya öğrenci bilgisi eksik');
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final startTime = now - (_elapsedSeconds * 1000); // Başlangıç zamanını hesapla

      final session = ReadingSessionModel(
        id: _generateId(),
        studentId: _currentStudent!.id,
        storyId: _currentStory!.id,
        startTime: startTime,
        endTime: now,
        duration: _elapsedSeconds,
        wordCount: _currentStory!.wordCount,
        wpm: _wordsPerMinute.toDouble(),
        completionRate: _progress * 100,
        isCompleted: true,
        createdAt: now,
      );

      // Store current session for quiz access
      _currentSession = session;

      await _db.insert('reading_sessions', session.toMap());
    } catch (e) {
      throw Exception('Okuma oturumu kaydetme hatası: $e');
    }
  }

  /// Öğrencinin okuma geçmişini al
  Future<List<ReadingSessionModel>> getReadingHistory(String studentId) async {
    try {
      final results = await _db.query(
        'reading_sessions',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'created_at DESC',
      );

      return results.map((map) => ReadingSessionModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Okuma geçmişi alma hatası: $e');
    }
  }

  /// Hikaye için okuma sayısını al
  Future<int> getStoryReadCount(String storyId, String studentId) async {
    try {
      final results = await _db.query(
        'reading_sessions',
        where: 'story_id = ? AND student_id = ?',
        whereArgs: [storyId, studentId],
      );

      return results.length;
    } catch (e) {
      return 0;
    }
  }

  /// Ortalama WPM hesapla
  Future<int> getAverageWPM(String studentId) async {
    try {
      final sessions = await getReadingHistory(studentId);
      
      if (sessions.isEmpty) return 0;
      
      final totalWPM = sessions.fold<int>(
        0,
        (sum, session) => sum + (session.wpm?.round() ?? 0),
      );
      
      return (totalWPM / sessions.length).round();
    } catch (e) {
      return 0;
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// State'i sıfırla
  void _resetState() {
    _currentStory = null;
    _currentStudent = null;
    _currentSession = null;
    _isReading = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _wordsPerMinute = 0;
    _progress = 0.0;
    _clearError();
    notifyListeners();
  }

  /// Hata mesajını ayarla
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Hatayı temizle
  void _clearError() {
    _errorMessage = null;
  }

  /// Hatayı manuel temizle (UI'dan)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Benzersiz ID oluştur
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// Controller'ı temizle
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
