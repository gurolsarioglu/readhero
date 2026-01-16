/// Okuma oturumu modeli
class ReadingSessionModel {
  final String id;
  final String studentId;
  final String storyId;
  final int startTime;
  final int? endTime;
  final int? duration; // saniye
  final int wordCount;
  final double? wpm; // Words Per Minute
  final double completionRate; // %
  final String? audioPath; // 1. sınıf için ses kaydı
  final bool isCompleted;
  final int createdAt;

  ReadingSessionModel({
    required this.id,
    required this.studentId,
    required this.storyId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.wordCount,
    this.wpm,
    this.completionRate = 100.0,
    this.audioPath,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// JSON'dan model oluştur
  factory ReadingSessionModel.fromJson(Map<String, dynamic> json) {
    return ReadingSessionModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      storyId: json['story_id'] as String,
      startTime: json['start_time'] as int,
      endTime: json['end_time'] as int?,
      duration: json['duration'] as int?,
      wordCount: json['word_count'] as int,
      wpm: (json['wpm'] as num?)?.toDouble(),
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 100.0,
      audioPath: json['audio_path'] as String?,
      isCompleted: (json['is_completed'] as int?) == 1,
      createdAt: json['created_at'] as int,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'story_id': storyId,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'word_count': wordCount,
      'wpm': wpm,
      'completion_rate': completionRate,
      'audio_path': audioPath,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
    };
  }

  /// Database Map'ten model oluştur
  factory ReadingSessionModel.fromMap(Map<String, dynamic> map) {
    return ReadingSessionModel.fromJson(map);
  }

  /// Model'i Database Map'e çevir
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Kopya oluştur
  ReadingSessionModel copyWith({
    String? id,
    String? studentId,
    String? storyId,
    int? startTime,
    int? endTime,
    int? duration,
    int? wordCount,
    double? wpm,
    double? completionRate,
    String? audioPath,
    bool? isCompleted,
    int? createdAt,
  }) {
    return ReadingSessionModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      storyId: storyId ?? this.storyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      wordCount: wordCount ?? this.wordCount,
      wpm: wpm ?? this.wpm,
      completionRate: completionRate ?? this.completionRate,
      audioPath: audioPath ?? this.audioPath,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Oturumu tamamla ve WPM hesapla
  ReadingSessionModel complete(int endTime) {
    final sessionDuration = endTime - startTime;
    final durationInMinutes = sessionDuration / 60.0;
    final calculatedWPM = durationInMinutes > 0 ? (wordCount / durationInMinutes).toDouble() : 0.0;

    return copyWith(
      endTime: endTime,
      duration: sessionDuration,
      wpm: calculatedWPM,
      isCompleted: true,
    );
  }

  /// Okuma süresi (dakika:saniye formatında)
  String get formattedDuration {
    if (duration == null) return '00:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// WPM formatlanmış (tam sayı)
  String get formattedWPM {
    if (wpm == null) return '-';
    return wpm!.round().toString();
  }

  @override
  String toString() {
    return 'ReadingSessionModel(id: $id, student: $studentId, wpm: ${formattedWPM})';
  }
}
