/// Ses kaydı modeli
class AudioRecording {
  final String id;
  final String studentId;
  final String storyId;
  final String filePath;
  final int duration; // Saniye cinsinden
  final DateTime recordedAt;
  final int fileSize; // Byte cinsinden
  final String? storyTitle;

  AudioRecording({
    required this.id,
    required this.studentId,
    required this.storyId,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    this.fileSize = 0,
    this.storyTitle,
  });

  /// Formatlanmış süre (mm:ss)
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatlanmış dosya boyutu
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Ses kalitesi göstergesi (dosya boyutuna göre)
  String get qualityIndicator {
    final kbPerSecond = (fileSize / 1024) / duration;
    if (kbPerSecond > 20) {
      return 'Yüksek';
    } else if (kbPerSecond > 10) {
      return 'Orta';
    } else {
      return 'Düşük';
    }
  }

  /// Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'story_id': storyId,
      'file_path': filePath,
      'duration': duration,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
      'file_size': fileSize,
      'story_title': storyTitle,
    };
  }

  /// Map'ten oluştur
  factory AudioRecording.fromMap(Map<String, dynamic> map) {
    return AudioRecording(
      id: map['id'],
      studentId: map['student_id'],
      storyId: map['story_id'],
      filePath: map['file_path'],
      duration: map['duration'],
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at']),
      fileSize: map['file_size'] ?? 0,
      storyTitle: map['story_title'],
    );
  }

  /// Kopyala
  AudioRecording copyWith({
    String? id,
    String? studentId,
    String? storyId,
    String? filePath,
    int? duration,
    DateTime? recordedAt,
    int? fileSize,
    String? storyTitle,
  }) {
    return AudioRecording(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      storyId: storyId ?? this.storyId,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      fileSize: fileSize ?? this.fileSize,
      storyTitle: storyTitle ?? this.storyTitle,
    );
  }
}
