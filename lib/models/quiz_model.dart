import 'dart:convert';

/// Soru modeli
class QuestionModel {
  final String id;
  final String type; // general, vocabulary, inference
  final String difficulty; // easy, medium, hard
  final String question;
  final List<String> options;
  final int correctAnswer; // index (0-3)
  final String? explanation;

  QuestionModel({
    this.id = '',
    this.type = 'general',
    this.difficulty = 'medium',
    this.question = '',
    this.options = const [],
    this.correctAnswer = 0,
    this.explanation,
  });

  /// JSON'dan model oluştur
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'general',
      difficulty: (json['difficulty'] as String?) ?? 'medium',
      question: (json['question'] as String?) ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: (json['correctAnswer'] ?? json['correct_answer'] ?? 0) as int,
      explanation: (json['explanation'] as String?) ?? '',
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'difficulty': difficulty,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel.fromJson(map);
  Map<String, dynamic> toMap() => toJson();

  @override
  String toString() => 'QuestionModel(id: $id, q: $question)';
}

/// Quiz modeli
class QuizModel {
  final String id;
  final String storyId;
  final List<QuestionModel> questions;
  final int createdAt;

  QuizModel({
    this.id = '',
    this.storyId = '',
    this.questions = const [],
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// JSON'dan model oluştur
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: (json['id'] as String?) ?? '',
      storyId: (json['story_id'] ?? json['storyId'] ?? '') as String,
      questions: _parseQuestions(json['questions']),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch) as int,
    );
  }

  static List<QuestionModel> _parseQuestions(dynamic questionsData) {
    if (questionsData == null) return [];
    if (questionsData is String) {
      try {
        final List<dynamic> decoded = jsonDecode(questionsData);
        return decoded.map((e) => QuestionModel.fromMap(e)).toList();
      } catch (e) {
        return [];
      }
    }
    if (questionsData is List) {
      return questionsData.map((e) => QuestionModel.fromMap(e)).toList();
    }
    return [];
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story_id': storyId,
      'questions': jsonEncode(questions.map((q) => q.toMap()).toList()),
      'created_at': createdAt,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) => QuizModel.fromJson(map);
  Map<String, dynamic> toMap() => toJson();
}
