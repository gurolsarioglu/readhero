/// Ödül modeli
class RewardModel {
  final String id;
  final String studentId;
  final String title;
  final String? description;
  final int requiredPoints;
  final bool isUnlocked;
  final int? unlockedAt;
  final bool isClaimed;
  final int? claimedAt;
  final String createdBy; // Veli ID
  final int createdAt;

  RewardModel({
    this.id = '',
    this.studentId = '',
    this.title = '',
    this.description,
    this.requiredPoints = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isClaimed = false,
    this.claimedAt,
    this.createdBy = '',
    int? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// JSON'dan model oluştur
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: (json['id'] as String?) ?? '',
      studentId: (json['student_id'] ?? json['studentId'] ?? '') as String,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      requiredPoints: (json['required_points'] ?? json['requiredPoints'] ?? 0) as int,
      isUnlocked: (json['is_unlocked'] ?? json['isUnlocked'] ?? 0) == 1,
      unlockedAt: (json['unlocked_at'] ?? json['unlockedAt']) as int?,
      isClaimed: (json['is_claimed'] ?? json['isClaimed'] ?? 0) == 1,
      claimedAt: (json['claimed_at'] ?? json['claimedAt']) as int?,
      createdBy: (json['created_by'] ?? json['createdBy'] ?? '') as String,
      createdAt: (json['created_at'] ?? json['createdAt']) as int?,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'description': description,
      'required_points': requiredPoints,
      'is_unlocked': isUnlocked ? 1 : 0,
      'unlocked_at': unlockedAt,
      'is_claimed': isClaimed ? 1 : 0,
      'claimed_at': claimedAt,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }

  /// Database Map'ten model oluştur
  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel.fromJson(map);
  }

  /// Model'i Database Map'e çevir
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Kopya oluştur
  RewardModel copyWith({
    String? id,
    String? studentId,
    String? title,
    String? description,
    int? requiredPoints,
    bool? isUnlocked,
    int? unlockedAt,
    bool? isClaimed,
    int? claimedAt,
    String? createdBy,
    int? createdAt,
  }) {
    return RewardModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Ödülü aç
  RewardModel unlock() {
    return copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Ödülü talep et
  RewardModel claim() {
    if (!isUnlocked) {
      throw Exception('Reward must be unlocked before claiming');
    }
    return copyWith(
      isClaimed: true,
      claimedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Kilitli mi?
  bool get isLocked => !isUnlocked;

  /// Talep edilebilir mi?
  bool get canClaim => isUnlocked && !isClaimed;

  @override
  String toString() {
    return 'RewardModel(id: $id, title: $title, points: $requiredPoints, unlocked: $isUnlocked)';
  }
}
