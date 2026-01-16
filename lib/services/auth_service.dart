import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Kimlik doğrulama servisi
class AuthService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  UserModel? _currentUser;

  /// Mevcut kullanıcıyı al
  UserModel? get currentUser => _currentUser;

  /// Giriş yapılmış mı?
  bool get isLoggedIn => _currentUser != null;

  /// Kayıt ol
  Future<UserModel> register({
    required String email,
    required String phone,
    required String password,
    required String name,
  }) async {
    // Email kontrolü
    final existingEmail = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existingEmail.isNotEmpty) {
      throw Exception('Bu email adresi zaten kullanılıyor');
    }

    // Telefon kontrolü
    final existingPhone = await _db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    if (existingPhone.isNotEmpty) {
      throw Exception('Bu telefon numarası zaten kullanılıyor');
    }

    // Şifreyi hashle
    final passwordHash = _hashPassword(password);

    // Kullanıcı oluştur
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = UserModel(
      id: _generateId(),
      email: email,
      phone: phone,
      passwordHash: passwordHash,
      name: name,
      isVerified: false,
      emailVerified: false,
      phoneVerified: false,
      createdAt: now,
      updatedAt: now,
    );

    // Veritabanına kaydet
    await _db.insert('users', user.toMap());

    return user;
  }

  /// Giriş yap
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    // Email veya telefon ile kullanıcıyı bul
    final users = await _db.query(
      'users',
      where: 'email = ? OR phone = ?',
      whereArgs: [emailOrPhone, emailOrPhone],
      limit: 1,
    );

    if (users.isEmpty) {
      throw Exception('Kullanıcı bulunamadı');
    }

    final user = UserModel.fromMap(users.first);

    // Şifre kontrolü
    final passwordHash = _hashPassword(password);
    if (user.passwordHash != passwordHash) {
      throw Exception('Şifre hatalı');
    }

    // Oturumu kaydet
    _currentUser = user;

    return user;
  }

  /// Çıkış yap
  Future<void> logout() async {
    _currentUser = null;
  }

  /// Email doğrula
  Future<UserModel> verifyEmail(String userId) async {
    final user = await _getUserById(userId);
    final updatedUser = user.copyWith(
      emailVerified: true,
      isVerified: user.phoneVerified, // Her ikisi de doğrulandıysa
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('users', updatedUser.toMap(), userId);
    
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }

    return updatedUser;
  }

  /// Telefon doğrula
  Future<UserModel> verifyPhone(String userId) async {
    final user = await _getUserById(userId);
    final updatedUser = user.copyWith(
      phoneVerified: true,
      isVerified: user.emailVerified, // Her ikisi de doğrulandıysa
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('users', updatedUser.toMap(), userId);
    
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }

    return updatedUser;
  }

  /// Şifre değiştir
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = await _getUserById(userId);

    // Eski şifre kontrolü
    final oldPasswordHash = _hashPassword(oldPassword);
    if (user.passwordHash != oldPasswordHash) {
      throw Exception('Mevcut şifre hatalı');
    }

    // Yeni şifreyi hashle ve güncelle
    final newPasswordHash = _hashPassword(newPassword);
    final updatedUser = user.copyWith(
      passwordHash: newPasswordHash,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('users', updatedUser.toMap(), userId);
  }

  /// Şifre sıfırlama (email/SMS ile)
  Future<void> resetPassword({
    required String emailOrPhone,
    required String newPassword,
  }) async {
    final users = await _db.query(
      'users',
      where: 'email = ? OR phone = ?',
      whereArgs: [emailOrPhone, emailOrPhone],
      limit: 1,
    );

    if (users.isEmpty) {
      throw Exception('Kullanıcı bulunamadı');
    }

    final user = UserModel.fromMap(users.first);
    final newPasswordHash = _hashPassword(newPassword);
    final updatedUser = user.copyWith(
      passwordHash: newPasswordHash,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('users', updatedUser.toMap(), user.id);
  }

  /// Kullanıcı bilgilerini güncelle
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final user = await _getUserById(userId);

    // Email değişiyorsa kontrol et
    if (email != null && email != user.email) {
      final existingEmail = await _db.query(
        'users',
        where: 'email = ? AND id != ?',
        whereArgs: [email, userId],
      );
      if (existingEmail.isNotEmpty) {
        throw Exception('Bu email adresi zaten kullanılıyor');
      }
    }

    // Telefon değişiyorsa kontrol et
    if (phone != null && phone != user.phone) {
      final existingPhone = await _db.query(
        'users',
        where: 'phone = ? AND id != ?',
        whereArgs: [phone, userId],
      );
      if (existingPhone.isNotEmpty) {
        throw Exception('Bu telefon numarası zaten kullanılıyor');
      }
    }

    final updatedUser = user.copyWith(
      name: name,
      email: email,
      phone: phone,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('users', updatedUser.toMap(), userId);

    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }

    return updatedUser;
  }

  /// Hesabı sil
  Future<void> deleteAccount(String userId) async {
    await _db.delete('users', userId);
    
    if (_currentUser?.id == userId) {
      _currentUser = null;
    }
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Kullanıcıyı ID ile al
  Future<UserModel> _getUserById(String userId) async {
    final userMap = await _db.getById('users', userId);
    if (userMap == null) {
      throw Exception('Kullanıcı bulunamadı');
    }
    return UserModel.fromMap(userMap);
  }

  /// Şifreyi hashle (SHA-256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Benzersiz ID oluştur
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// Oturumu yükle (uygulama başlangıcında)
  Future<void> loadSession(String userId) async {
    try {
      _currentUser = await _getUserById(userId);
    } catch (e) {
      _currentUser = null;
    }
  }
}
