import 'dart:convert';
import 'dart:ui';

/// Hikaye modeli
class StoryModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final int gradeLevel;
  final int wordCount;
  final String difficulty;
  final List<String> keywords;
  final String? moralLesson;
  final bool isOffline;
  final bool isAIGenerated;
  final String source;
  final int createdAt;
  final int updatedAt;

  StoryModel({
    this.id = '',
    this.title = '',
    this.content = '',
    this.category = '',
    this.gradeLevel = 1,
    this.wordCount = 0,
    this.difficulty = 'medium',
    this.keywords = const [],
    this.moralLesson,
    this.isOffline = false,
    this.isAIGenerated = false,
    this.source = 'builtin',
    int? createdAt,
    int? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
       updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      gradeLevel: (json['grade_level'] ?? json['gradeLevel'] ?? 1) as int,
      wordCount: (json['word_count'] ?? json['wordCount'] ?? 0) as int,
      difficulty: (json['difficulty'] as String?) ?? 'medium',
      keywords: _parseKeywords(json['keywords']),
      moralLesson: (json['moral_lesson'] ?? json['moralLesson']) as String?,
      isOffline: (json['is_offline'] ?? json['isOffline'] ?? 0) == 1 || (json['isOffline'] == true),
      isAIGenerated: (json['is_ai_generated'] ?? json['isAIGenerated'] ?? 0) == 1 || (json['isAIGenerated'] == true),
      source: (json['source'] as String?) ?? 'builtin',
      createdAt: (json['created_at'] ?? json['createdAt']) as int?,
      updatedAt: (json['updated_at'] ?? json['updatedAt']) as int?,
    );
  }

  static List<String> _parseKeywords(dynamic keywordsData) {
    if (keywordsData == null) return [];
    if (keywordsData is String) {
      try {
        final List<dynamic> decoded = jsonDecode(keywordsData);
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    if (keywordsData is List) {
      return keywordsData.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'grade_level': gradeLevel,
      'word_count': wordCount,
      'difficulty': difficulty,
      'keywords': jsonEncode(keywords),
      'moral_lesson': moralLesson,
      'is_offline': isOffline ? 1 : 0,
      'is_ai_generated': isAIGenerated ? 1 : 0,
      'source': source,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) => StoryModel.fromJson(map);
  Map<String, dynamic> toMap() => toJson();

  StoryModel copyWith({
    String? id, String? title, String? content, String? category,
    int? gradeLevel, int? wordCount, String? difficulty,
    List<String>? keywords, String? moralLesson, bool? isOffline,
    bool? isAIGenerated, String? source, int? createdAt, int? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      wordCount: wordCount ?? this.wordCount,
      difficulty: difficulty ?? this.difficulty,
      keywords: keywords ?? this.keywords,
      moralLesson: moralLesson ?? this.moralLesson,
      isOffline: isOffline ?? this.isOffline,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get estimatedReadingTime {
    final avgWPM = 40 + (gradeLevel * 20);
    return (wordCount / avgWPM).ceil();
  }
  
  /// Zorluk seviyesine göre renk döndür
  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'kolay':
        return const Color(0xFF4CAF50); // Green
      case 'hard':
      case 'zor':
        return const Color(0xFFF44336); // Red
      default: // medium, orta
        return const Color(0xFFFF9800); // Orange
    }
  }

  @override
  String toString() => 'StoryModel(id: $id, title: $title)';
}
