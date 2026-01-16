import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readhero/models/models.dart';

class AIService extends ChangeNotifier {
  static final AIService instance = AIService._();
  AIService._();
  factory AIService() => instance;
  
  GenerativeModel? _model;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final key = dotenv.env['GEMINI_API_KEY'];
      if (key == null) return;
      _model = GenerativeModel(model: 'gemini-pro', apiKey: key);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AI Init Error: $e');
    }
  }
  
  Future<String> generateText(String prompt) async {
    if (!_isInitialized || _model == null) await initialize();
    if (_model == null) return '';
    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<StoryModel> generateStory({required int gradeLevel, required String category, String? difficulty, String? theme}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final text = await generateText('Çocuk hikayesi yaz. Sınıf: $gradeLevel, Kategori: $category, Tema: $theme. JSON döndür: {"title": "...", "content": "..."}');
    
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
    
    Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned.trim());
    } catch (e) {
      json = {'title': 'Yeni Hikaye', 'content': text};
    }

    return StoryModel(
      id: 'ai_$now',
      title: json['title'] ?? 'Yapay Zeka Hikayesi',
      content: json['content'] ?? text,
      category: category,
      gradeLevel: gradeLevel,
      wordCount: (json['content'] as String? ?? '').split(' ').length,
      difficulty: difficulty ?? 'medium',
      isAIGenerated: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Kelime anlamını açıkla - kelime defteri için
  Future<String> explainWord(String word) async {
    final prompt = '''
"$word" kelimesinin Türkçe anlamını ve örnek bir cümle yaz.
Format: Anlam: [anlam] Örnek: [örnek cümle]
Kısa ve çocukların anlayabileceği şekilde yaz.
''';
    final result = await generateText(prompt);
    if (result.isEmpty) {
      return 'Anlam: Bu kelimenin anlamı yüklenemedi.';
    }
    return result;
  }
}

class StoryGenerator {
  static final StoryGenerator instance = StoryGenerator();
  Future<StoryModel> generateStory({required int gradeLevel, required String category, required String difficulty, String? theme}) async {
    return await AIService.instance.generateStory(gradeLevel: gradeLevel, category: category, difficulty: difficulty, theme: theme);
  }
  static const List<String> categories = ['Macera', 'Dostluk', 'Hayvanlar', 'Doğa', 'Bilim'];
  static const List<String> difficulties = ['kolay', 'orta', 'zor'];
}

class QuizGenerator {
  static final QuizGenerator instance = QuizGenerator();
  Future<QuizModel> generateQuiz(String storyId, String storyTitle, String storyContent) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final text = await AIService.instance.generateText('Hikaye için 5 soru yaz: $storyTitle. JSON döndür: {"questions": [{"question": "...", "options": ["...", "...", "...", "..."], "correctAnswer": 0, "explanation": "..."}]}');
    
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
    
    Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned.trim());
    } catch (e) {
      json = {'questions': []};
    }

    final questionsData = json['questions'] as List? ?? [];
    int qIdx = 0;
    final questions = questionsData.map((q) => QuestionModel(
      id: 'q_${now}_${qIdx++}',
      question: q['question'] ?? '',
      options: List<String>.from(q['options'] ?? []),
      correctAnswer: (q['correctAnswer'] ?? 0) as int,
      explanation: q['explanation'] ?? '',
    )).toList();

    return QuizModel(
      id: 'quiz_$now',
      storyId: storyId,
      questions: questions,
      createdAt: now,
    );
  }
}
