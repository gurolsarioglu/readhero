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
      _generatedStory = await _storyGenerator.generateStory(
        gradeLevel: gradeLevel, 
        category: category, 
        difficulty: difficulty, 
        theme: theme
      );

      final quiz = await _quizGenerator.generateQuiz(
        _generatedStory!.id,
        _generatedStory!.title,
        _generatedStory!.content,
      );

      await _db.insertStory(_generatedStory!);
      await _db.insertQuiz(quiz);
      await storyController.loadStories();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
