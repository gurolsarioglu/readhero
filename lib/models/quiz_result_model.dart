import 'dart:convert';

class QuizResultModel {
  final String id;
  final String studentId;
  final String sessionId;
  final String quizId;
  final List<int> answers;
  final int correctCount;
  final int totalQuestions;
  final double score;
  final int completedAt;
  final int timeSpent;
  final String grade; // <--- Velinin beklediği 'A+', 'B' gibi not veya sınıf seviyesi

  bool get isPassed => score >= 60;
  bool get isPerfect => score >= 100;

  QuizResultModel({
    this.id = '',
    this.studentId = '',
    this.sessionId = '',
    this.quizId = '',
    this.answers = const [],
    this.correctCount = 0,
    this.totalQuestions = 0,
    this.score = 0.0,
    int? completedAt,
    this.timeSpent = 0,
    this.grade = 'A', // Varsayılan değer
  }) : completedAt = completedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: (json['id'] as String?) ?? '',
      studentId: (json['student_id'] ?? json['studentId'] ?? '') as String,
      sessionId: (json['session_id'] ?? json['sessionId'] ?? '') as String,
      quizId: (json['quiz_id'] ?? json['quizId'] ?? '') as String,
      answers: _parseAnswers(json['answers']),
      correctCount: (json['correct_count'] ?? json['correctCount'] ?? 0) as int,
      totalQuestions: (json['total_questions'] ?? json['totalQuestions'] ?? 0) as int,
      score: (json['score'] as num? ?? 0.0).toDouble(),
      completedAt: (json['completed_at'] ?? json['completedAt']) as int?,
      timeSpent: (json['time_spent'] ?? json['timeSpent'] ?? 0) as int,
      grade: (json['grade'] as String?) ?? _calculateGrade(json['score'] as num? ?? 0),
    );
  }

  static String _calculateGrade(num score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    return 'D';
  }

  static List<int> _parseAnswers(dynamic answersData) {
    if (answersData == null) return [];
    if (answersData is String) {
      final List<dynamic> decoded = jsonDecode(answersData);
      return decoded.map((e) => int.parse(e.toString())).toList();
    }
    return List<int>.from(answersData);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'session_id': sessionId,
      'quiz_id': quizId,
      'answers': jsonEncode(answers),
      'correct_count': correctCount,
      'total_questions': totalQuestions,
      'score': score,
      'completed_at': completedAt,
      'time_spent': timeSpent,
      'grade': grade,
    };
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> map) => QuizResultModel.fromJson(map);
}
