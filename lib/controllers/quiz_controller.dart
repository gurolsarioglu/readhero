import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/points_service.dart';
import '../services/goal_service.dart';
import 'dart:math';

/// Quiz Controller - Sınav mantığını yönetir
/// 
/// Özellikler:
/// - Quiz yükleme ve soru seçimi
/// - Cevap kontrolü ve puanlama
/// - Sonuç kaydetme
/// - Rastgele soru seçimi
class QuizController extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final PointsService _pointsService = PointsService();
  
  // State
  QuizModel? _currentQuiz;
  List<QuestionModel> _selectedQuestions = [];
  Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex
  int _currentQuestionIndex = 0;
  int _timeRemaining = 600; // 10 dakika (saniye)
  bool _isQuizActive = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  QuizModel? get currentQuiz => _currentQuiz;
  List<QuestionModel> get selectedQuestions => _selectedQuestions;
  QuestionModel? get currentQuestion => _selectedQuestions.isNotEmpty && _currentQuestionIndex < _selectedQuestions.length
      ? _selectedQuestions[_currentQuestionIndex]
      : null;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _selectedQuestions.length;
  int get timeRemaining => _timeRemaining;
  bool get isQuizActive => _isQuizActive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLastQuestion => _currentQuestionIndex >= _selectedQuestions.length - 1;
  int? get currentAnswer => _userAnswers[_currentQuestionIndex];
  
  // Zamanlayıcı
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isQuizActive && _timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
        _startTimer();
      } else if (_timeRemaining <= 0) {
        // Süre doldu, otomatik bitir
        finishQuiz(_currentSessionId ?? '');
      }
    });
  }
  
  /// Quiz yükle ve rastgele sorular seç
  Future<void> loadQuiz(String storyId, {int questionCount = 5}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Quiz'i veritabanından al
      final quizData = await _db.getQuizByStoryId(storyId);
      
      if (quizData == null) {
        throw Exception('Bu hikaye için sınav bulunamadı');
      }
      
      _currentQuiz = quizData;
      
      // Rastgele sorular seç
      _selectedQuestions = _getRandomQuestions(questionCount);
      
      if (_selectedQuestions.isEmpty) {
        throw Exception('Sınav soruları yüklenemedi');
      }
      
      // State'i sıfırla
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _timeRemaining = 600; // 10 dakika
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Quiz yükleme hatası: $e');
    }
  }
  
  /// Rastgele soru seçimi
  List<QuestionModel> _getRandomQuestions(int count) {
    if (_currentQuiz == null || _currentQuiz!.questions.isEmpty) {
      return [];
    }
    
    final allQuestions = List<QuestionModel>.from(_currentQuiz!.questions);
    
    // Eğer istenen sayıdan az soru varsa, hepsini döndür
    if (allQuestions.length <= count) {
      allQuestions.shuffle();
      return allQuestions;
    }
    
    // Rastgele seç
    allQuestions.shuffle(Random());
    return allQuestions.take(count).toList();
  }
  
  String? _currentSessionId;

  /// Sınavı başlat
  void startQuiz(String sessionId) {
    _currentSessionId = sessionId;
    if (_selectedQuestions.isEmpty) {
      _errorMessage = 'Önce quiz yüklenmelidir';
      notifyListeners();
      return;
    }
    
    _isQuizActive = true;
    _startTimer();
    notifyListeners();
  }
  
  /// Cevap seç
  void selectAnswer(int optionIndex) {
    if (!_isQuizActive) return;
    
    _userAnswers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }
  
  /// Sonraki soruya geç
  void nextQuestion() {
    if (_currentQuestionIndex < _selectedQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }
  
  /// Önceki soruya dön
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }
  
  /// Belirli bir soruya git
  void goToQuestion(int index) {
    if (index >= 0 && index < _selectedQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }
  
  /// Sınavı bitir ve sonuçları hesapla
  Future<QuizResultModel?> finishQuiz(String sessionId) async {
    try {
      _isQuizActive = false;
      notifyListeners();
      
      if (_currentQuiz == null) {
        throw Exception('Aktif quiz bulunamadı');
      }
      
      // Puanı hesapla
      int correctAnswers = 0;
      
      for (int i = 0; i < _selectedQuestions.length; i++) {
        final question = _selectedQuestions[i];
        final userAnswer = _userAnswers[i];
        
        if (userAnswer != null && userAnswer == question.correctAnswer) {
          correctAnswers++;
        }
      }
      
      int totalQuestions = _selectedQuestions.length;
      final score = (correctAnswers / totalQuestions * 100).round().toDouble();
      
      // Session'dan student ID al
      final sessionData = await _db.getById('reading_sessions', sessionId);
      final studentId = sessionData?['student_id'] as String? ?? '';
      
      // Sonucu oluştur
      final result = QuizResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        sessionId: sessionId,
        quizId: _currentQuiz!.id,
        answers: List.generate(totalQuestions, (i) => _userAnswers[i] ?? -1),
        correctCount: correctAnswers,
        totalQuestions: totalQuestions,
        score: score,
        completedAt: DateTime.now().millisecondsSinceEpoch,
        timeSpent: 600 - _timeRemaining,
      );
      
      // Veritabanına kaydet
      await _db.insertQuizResult(result);
      
      // Puan hesapla ve ekle
      try {
        if (sessionData != null) {
          final session = ReadingSessionModel.fromMap(sessionData);
          final studentData = await _db.getById('students', session.studentId);
          
          if (studentData != null) {
            final student = StudentModel.fromMap(studentData);
            
            // Quiz puanını hesapla
            final quizPoints = _pointsService.calculateQuizPoints(score: score.toInt());
            
            // Okuma puanını hesapla
            final readingPoints = _pointsService.calculateReadingPoints(
              gradeLevel: student.gradeLevel,
              wpm: session.wpm ?? 0.0,
              isCompleted: session.isCompleted,
            );
            
            final totalPoints = quizPoints + readingPoints;
            
            // Puanı ekle
            await _pointsService.addPoints(
              studentId: student.id,
              points: totalPoints,
              reason: 'Okuma + Sınav tamamlandı (Okuma: $readingPoints, Sınav: $quizPoints)',
            );
            
            // Rozet kontrolü
            await _pointsService.checkAndAwardBadges(student.id);
            
            // Hedefleri güncelle
            try {
              final goalService = GoalService.instance;
              await goalService.updateQuizzesPassedGoal(student.id);
              if (score >= 100) {
                await goalService.updatePerfectScoresGoal(student.id);
              }
            } catch (e) {
              debugPrint('⚠️ Hedef güncelleme hatası: $e');
            }
            
            debugPrint('✅ Toplam $totalPoints puan eklendi (Okuma: $readingPoints, Sınav: $quizPoints)');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Puan ekleme hatası: $e');
        // Puan ekleme hatası quiz sonucunu etkilemez
      }
      
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Quiz bitirme hatası: $e');
      return null;
    }
  }
  
  /// Mevcut sorunun doğru cevabını kontrol et
  bool isCurrentAnswerCorrect() {
    if (currentQuestion == null || currentAnswer == null) {
      return false;
    }
    return currentAnswer == currentQuestion!.correctAnswer;
  }
  
  /// Tüm cevapları kontrol et (kaç doğru, kaç yanlış)
  Map<String, int> checkAllAnswers() {
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;
    
    for (int i = 0; i < _selectedQuestions.length; i++) {
      final question = _selectedQuestions[i];
      final userAnswer = _userAnswers[i];
      
      if (userAnswer == null) {
        unanswered++;
      } else if (userAnswer == question.correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }
    
    return {
      'correct': correct,
      'wrong': wrong,
      'unanswered': unanswered,
    };
  }
  
  /// Formatlanmış süre (MM:SS)
  String get formattedTime {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// İlerleme yüzdesi
  double get progressPercentage {
    if (_selectedQuestions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _selectedQuestions.length;
  }
  
  /// Cevaplanmış soru sayısı
  int get answeredQuestionsCount => _userAnswers.length;
  
  /// Tüm sorular cevaplanmış mı?
  bool get allQuestionsAnswered => _userAnswers.length == _selectedQuestions.length;
  
  /// State'i sıfırla
  void reset() {
    _currentQuiz = null;
    _selectedQuestions.clear();
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    _timeRemaining = 600;
    _isQuizActive = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Belirli bir öğrencinin quiz geçmişini getir
  Future<List<QuizResultModel>> getStudentQuizHistory(String studentId) async {
    try {
      return await _db.getQuizResultsByStudent(studentId);
    } catch (e) {
      debugPrint('Quiz geçmişi getirme hatası: $e');
      return [];
    }
  }
  
  /// Belirli bir hikaye için quiz sonuçlarını getir
  Future<List<QuizResultModel>> getStoryQuizResults(String storyId) async {
    try {
      return await _db.getQuizResultsByStory(storyId);
    } catch (e) {
      debugPrint('Quiz sonuçları getirme hatası: $e');
      return [];
    }
  }
}
