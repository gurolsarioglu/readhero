import 'package:flutter/material.dart';
import 'package:readhero/services/ai_all_in_one.dart';
import 'package:readhero/models/models.dart';
import 'package:readhero/controllers/story_controller.dart';
import 'package:readhero/database/database_helper.dart';

class AIController extends ChangeNotifier {
  final AIService _aiService = AIService.instance;
  final StoryGenerator _storyGenerator = StoryGenerator.instance;
  final QuizGenerator _quizGenerator = QuizGenerator.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isLoading = false;
  String? _errorMessage;
  StoryModel? _generatedStory;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  StoryModel? get generatedStory => _generatedStory;
  bool get isInitialized => _aiService.isInitialized;
  
  List<String> get categories => StoryGenerator.categories;

  Future<void> initialize() async {
    await _aiService.initialize();
    notifyListeners();
  }

  Future<StoryModel?> generateStory({
    required int gradeLevel,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _generatedStory = await _aiService.generateStory(
        gradeLevel: gradeLevel, 
        category: category
      );
      _isLoading = false;
      notifyListeners();
      return _generatedStory;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> generateFullContent({
    required int gradeLevel,
    required String category,
    required String difficulty,
    String? theme,
    required StoryController storyController,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🤖 AI Hikaye oluşturma başladı...');
      debugPrint('📊 Parametreler: Sınıf=$gradeLevel, Kategori=$category, Zorluk=$difficulty, Tema=$theme');
      
      _generatedStory = await _storyGenerator.generateStory(
        gradeLevel: gradeLevel, 
        category: category, 
        difficulty: difficulty, 
        theme: theme
      );

      debugPrint('✅ Hikaye oluşturuldu: ${_generatedStory!.title}');
      debugPrint('🎯 Quiz oluşturma başlıyor...');

      final quiz = await _quizGenerator.generateQuiz(
        _generatedStory!.id,
        _generatedStory!.title,
        _generatedStory!.content,
      );

      debugPrint('✅ Quiz oluşturuldu: ${quiz.questions.length} soru');
      debugPrint('💾 Veritabanına kaydediliyor...');

      await _db.insertStory(_generatedStory!);
      debugPrint('✅ Hikaye DB\'ye kaydedildi');
      
      await _db.insertQuiz(quiz);
      debugPrint('✅ Quiz DB\'ye kaydedildi');
      
      await storyController.loadStories();
      debugPrint('✅ Hikayeler yeniden yüklendi');
      
      _isLoading = false;
      notifyListeners();
      debugPrint('🎉 İşlem tamamlandı!');
    } catch (e) {
      debugPrint('❌ HATA: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<QuizModel?> generateQuizForStory(StoryModel story) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Önce bu hikaye için eski quizleri temizle (isteğe bağlı, yeni mantıkta her seferinde yeni quiz isteniyor)
      // Ancak veritabanında story_id unique key değilse sorun olmaz, değilse çakışma olabilir.
      // Quiz tablosunu kontrol etmedik ama genelde id PK'dir. StoryId FK'dir.
      
      // 2. Yeni quiz oluştur
      final quiz = await _quizGenerator.generateQuiz(
        story.id,
        story.title,
        story.content,
      );

      // 3. Veritabanına kaydet
      // Eğer aynı story_id için birden fazla quiz olabiliyorsa sorun yok.
      // Ancak `getQuizByStoryId` metodu muhtemelen tek bir quiz döndürüyor.
      // Bu yüzden önce var olanı silmek veya güncellemek daha güvenli olabilir.
      // Şimdilik insertQuiz replacement mantığıyla çalışıyorsa sorun olmaz.
      await _db.insertQuiz(quiz); // insertQuiz genelde insertConflict: replace çalışırsa iyi olur.
      
      _isLoading = false;
      notifyListeners();
      return quiz;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
