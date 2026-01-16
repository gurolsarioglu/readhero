/// Veli (Parent/User) modeli
class UserModel {
  final String id;
  final String email;
  final String phone;
  final String passwordHash;
  final String name;
  final bool isVerified;
  final bool emailVerified;
  final bool phoneVerified;
  final int createdAt;
  final int updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.name,
    this.isVerified = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan model oluştur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      passwordHash: json['password_hash'] as String,
      name: json['name'] as String,
      isVerified: (json['is_verified'] as int) == 1,
      emailVerified: (json['email_verified'] as int) == 1,
      phoneVerified: (json['phone_verified'] as int) == 1,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'name': name,
      'is_verified': isVerified ? 1 : 0,
      'email_verified': emailVerified ? 1 : 0,
      'phone_verified': phoneVerified ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Database Map'ten model oluştur
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel.fromJson(map);
  }

  /// Model'i Database Map'e çevir
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// Kopya oluştur (değişikliklerle)
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? passwordHash,
    String? name,
    bool? isVerified,
    bool? emailVerified,
    bool? phoneVerified,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      isVerified: isVerified ?? this.isVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name)';
  }
}
