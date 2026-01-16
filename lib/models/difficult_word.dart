/// Zorlanılan kelime modeli
class DifficultWord {
  final String id;
  final String studentId;
  final String storyId;
  final String word;
  final String? meaning;
  final String? exampleSentence;
  final DateTime markedAt;
  final int reviewCount; // Kaç kez tekrar edildi
  final bool isLearned; // Öğrenildi mi?
  final DateTime? learnedAt;

  DifficultWord({
    this.id = '',
    this.studentId = '',
    this.storyId = '',
    this.word = '',
    this.meaning,
    this.exampleSentence,
    DateTime? markedAt,
    this.reviewCount = 0,
    this.isLearned = false,
    this.learnedAt,
  }) : this.markedAt = markedAt ?? DateTime.now();

  /// Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'story_id': storyId,
      'word': word,
      'meaning': meaning,
      'example_sentence': exampleSentence,
      'marked_at': markedAt.millisecondsSinceEpoch,
      'review_count': reviewCount,
      'is_learned': isLearned ? 1 : 0,
      'learned_at': learnedAt?.millisecondsSinceEpoch,
    };
  }

  /// Map'ten oluştur
  factory DifficultWord.fromMap(Map<String, dynamic> map) {
    return DifficultWord(
      id: map['id'] ?? '',
      studentId: map['student_id'] ?? '',
      storyId: map['story_id'] ?? '',
      word: map['word'] ?? '',
      meaning: map['meaning'],
      exampleSentence: map['example_sentence'],
      markedAt: DateTime.fromMillisecondsSinceEpoch(map['marked_at'] ?? DateTime.now().millisecondsSinceEpoch),
      reviewCount: map['review_count'] ?? 0,
      isLearned: map['is_learned'] == 1,
      learnedAt: map['learned_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['learned_at'])
          : null,
    );
  }

  /// Kopyala
  DifficultWord copyWith({
    String? id,
    String? studentId,
    String? storyId,
    String? word,
    String? meaning,
    String? exampleSentence,
    DateTime? markedAt,
    int? reviewCount,
    bool? isLearned,
    DateTime? learnedAt,
  }) {
    return DifficultWord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      storyId: storyId ?? this.storyId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      markedAt: markedAt ?? this.markedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      isLearned: isLearned ?? this.isLearned,
      learnedAt: learnedAt ?? this.learnedAt,
    );
  }
}
