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
      debugPrint('⚠️ JSON parse hatası: $e');
      json = {'title': 'Yeni Hikaye', 'content': text};
    }

    final story = StoryModel(
      id: 'ai_$now',
      title: json['title'] ?? 'Yapay Zeka Hikayesi',
      content: json['content'] ?? text,
      category: category,
      gradeLevel: gradeLevel,
      wordCount: (json['content'] as String? ?? '').split(' ').length,
      difficulty: difficulty ?? 'medium',
      isAIGenerated: true,
      source: 'ai',
      createdAt: now,
      updatedAt: now,
    );
    
    debugPrint('✅ AI Hikaye oluşturuldu: ${story.title} (${story.id})');
    return story;
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
    debugPrint('🎯 Quiz oluşturma başladı: $storyTitle');
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // ✅ DAHA İYİ PROMPT - Türkçe + Detaylı
    final prompt = '''
Aşağıdaki hikaye için 5 adet çoktan seçmeli soru oluştur.

Hikaye: "$storyTitle"

İçerik:
${storyContent.length > 500 ? storyContent.substring(0, 500) + '...' : storyContent}

KURALLAR:
1. Sorular Türkçe
2. Her soru için 4 seçenek
3. Doğru cevap index (0, 1, 2, veya 3)
4. Açıklama ekle

JSON formatı:
{
  "questions": [
    {
      "question": "Soru metni?",
      "options": ["Seçenek A", "Seçenek B", "Seçenek C", "Seçenek D"],
      "correctAnswer": 0,
      "explanation": "Açıklama"
    }
  ]
}

SADECE JSON döndür.
''';

    try {
      debugPrint('📤 AI\'ya gönderiliyor...');
      final text = await AIService.instance.generateText(prompt);
      
      if (text.isEmpty) {
        debugPrint('❌ AI boş döndü → Fallback quiz');
        return _createFallbackQuiz(storyId, storyTitle, now);
      }
      
      debugPrint('📥 AI yanıtı alındı: ${text.length} char');
      
      // JSON temizle
      String cleaned = text.trim();
      if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
      if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
      if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
      cleaned = cleaned.trim();
      
      Map<String, dynamic> json;
      try {
        json = jsonDecode(cleaned);
        debugPrint('✅ JSON parse OK');
      } catch (e) {
        debugPrint('❌ JSON parse HATA: $e');
        debugPrint('📄 Raw: ${cleaned.substring(0, cleaned.length > 200 ? 200 : cleaned.length)}');
        return _createFallbackQuiz(storyId, storyTitle, now);
      }

      final questionsData = json['questions'] as List? ?? [];
      
      if (questionsData.isEmpty) {
        debugPrint('❌ Question array BOŞ → Fallback');
        return _createFallbackQuiz(storyId, storyTitle, now);
      }
      
      debugPrint('📝 ${questionsData.length} soru parse ediliyor...');
      
      int qIdx = 0;
      final questions = questionsData.map((q) {
        try {
          return QuestionModel(
            id: 'q_${now}_${qIdx++}',
            question: q['question'] ?? 'Soru yok',
            options: List<String>.from(q['options'] ?? ['A', 'B', 'C', 'D']),
            correctAnswer: (q['correctAnswer'] ?? 0) as int,
            explanation: q['explanation'] ?? '',
          );
        } catch (e) {
          debugPrint('⚠️ Soru parse hatası: $e');
          return null;
        }
      }).where((q) => q != null).cast<QuestionModel>().toList();

      if (questions.isEmpty) {
        debugPrint('❌ Parse sonrası 0 soru → Fallback');
        return _createFallbackQuiz(storyId, storyTitle, now);
      }

      final quiz = QuizModel(
        id: 'quiz_$now',
        storyId: storyId,
        questions: questions,
        createdAt: now,
      );
      
      debugPrint('✅ Quiz BAŞARILI: ${quiz.questions.length} soru');
      return quiz;
      
    } catch (e, stack) {
      debugPrint('❌ KRİTİK HATA: $e');
      debugPrint('📚 Stack: $stack');
      return _createFallbackQuiz(storyId, storyTitle, now);
    }
  }
  
  /// ✅ FALLBACK QUIZ - AI başarısız olursa
  QuizModel _createFallbackQuiz(String storyId, String storyTitle, int timestamp) {
    debugPrint('🔄 Fallback quiz oluşturuluyor...');
    
    final questions = [
      QuestionModel(
        id: 'fb_1_$timestamp',
        question: 'Bu hikayenin adı nedir?',
        options: [storyTitle, 'Başka Bir Hikaye', 'Farklı Başlık', 'Bilinmiyor'],
        correctAnswer: 0,
        explanation: 'Hikayenin başlığı: $storyTitle',
      ),
      QuestionModel(
        id: 'fb_2_$timestamp',
        question: 'Bu hikayeyi okudun mu?',
        options: ['Evet, okudum', 'Hayır', 'Kısmen', 'Hatırlamıyorum'],
        correctAnswer: 0,
        explanation: 'Hikayeyi bitirdin, tebrikler!',
      ),
      QuestionModel(
        id: 'fb_3_$timestamp',
        question: 'Hikayeden ne öğrendin?',
        options: ['Güzel bir ders', 'Hiçbir şey', 'Eğlenceli', 'Sıkıcı'],
        correctAnswer: 0,
        explanation: 'Her hikaye bize bir şeyler öğretir.',
      ),
    ];
    
    debugPrint('✅ Fallback quiz hazır: ${questions.length} soru');
    
    return QuizModel(
      id: 'quiz_fb_$timestamp',
      storyId: storyId,
      questions: questions,
      createdAt: timestamp,
    );
  }
}
