import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/story_service.dart';
import '../database/database_helper.dart';

class DatabaseSeeder {
  static final StoryService _storyService = StoryService();
  static final DatabaseHelper _db = DatabaseHelper.instance;

  /// Başlangıç verilerini yükle
  static Future<void> seedDatabase() async {
    final hasStories = await _storyService.hasStories();
    if (hasStories) {
      print('ℹ️ Veritabanında zaten hikaye var, seeder atlanıyor.');
      return;
    }

    print('🚀 Veritabanı tohumlanıyor (seeding)...');
    
    try {
      // 1-4. Sınıf Hikayeleri ve Quizleri
      for (int i = 1; i <= 4; i++) {
        await _seedGradeData(i);
      }
      
      print('✅ Veritabanı başarıyla tohumlandı.');
    } catch (e) {
      print('❌ Veritabanı tohumlama hatası: $e');
    }
  }

  static Future<void> _seedGradeData(int grade) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/stories/grade_${grade}_stories.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      // Hikayeleri yükle
      if (jsonData.containsKey('stories')) {
        final List<dynamic> storiesJson = jsonData['stories'];
        final List<StoryModel> stories = storiesJson.map((json) => StoryModel.fromJson(json)).toList();
        
        for (var story in stories) {
          await _storyService.saveStory(story);
        }
        print('📖 $grade. sınıf için ${stories.length} hikaye yüklendi.');
      }

      // Quizleri yükle
      if (jsonData.containsKey('quizzes')) {
        final List<dynamic> quizzesJson = jsonData['quizzes'];
        final List<QuizModel> quizzes = quizzesJson.map((json) => QuizModel.fromMap(json)).toList();
        
        for (var quiz in quizzes) {
          await _db.insertQuiz(quiz);
        }
        print('📝 $grade. sınıf için ${quizzes.length} quiz yüklendi.');
      }
    } catch (e) {
      print('⚠️ $grade. sınıf verileri yüklenemedi: $e');
      rethrow;
    }
  }
}
