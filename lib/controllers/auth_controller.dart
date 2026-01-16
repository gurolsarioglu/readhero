import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/validation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kimlik doğrulama controller'ı
/// Provider ile state management sağlar
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ==================== STATE ====================
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;

  // ==================== GETTERS ====================

  /// Mevcut kullanıcı
  UserModel? get currentUser => _currentUser;

  /// Yüklenme durumu
  bool get isLoading => _isLoading;

  /// Hata mesajı
  String? get errorMessage => _errorMessage;

  /// Giriş yapılmış mı?
  bool get isLoggedIn => _currentUser != null;

  /// Email doğrulandı mı?
  bool get isEmailVerified => _isEmailVerified;

  /// Telefon doğrulandı mı?
  bool get isPhoneVerified => _isPhoneVerified;

  /// Kullanıcı doğrulandı mı? (hem email hem telefon)
  bool get isVerified => _isEmailVerified && _isPhoneVerified;

  // ==================== KAYIT İŞLEMLERİ ====================

  /// Kayıt ol
  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validasyon
      final emailError = ValidationService.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        return false;
      }

      final phoneError = ValidationService.validatePhone(phone);
      if (phoneError != null) {
        _setError(phoneError);
        return false;
      }

      final passwordError = ValidationService.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final nameError = ValidationService.validateName(name);
      if (nameError != null) {
        _setError(nameError);
        return false;
      }

      // Telefonu normalize et
      final normalizedPhone = ValidationService.normalizePhone(phone);

      // Kayıt işlemi
      final user = await _authService.register(
        email: email.trim().toLowerCase(),
        phone: normalizedPhone,
        password: password,
        name: name.trim(),
      );

      _currentUser = user;
      _isEmailVerified = user.emailVerified;
      _isPhoneVerified = user.phoneVerified;

      // Oturumu kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== GİRİŞ İŞLEMLERİ ====================

  /// Giriş yap
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validasyon
      if (emailOrPhone.isEmpty) {
        _setError('Email veya telefon gerekli');
        return false;
      }

      final passwordError = ValidationService.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      // Email mi telefon mu kontrol et
      String loginValue = emailOrPhone.trim();
      if (emailOrPhone.contains('@')) {
        loginValue = emailOrPhone.toLowerCase();
      } else {
        loginValue = ValidationService.normalizePhone(emailOrPhone);
      }

      // Giriş işlemi
      final user = await _authService.login(
        emailOrPhone: loginValue,
        password: password,
      );

      _currentUser = user;
      _isEmailVerified = user.emailVerified;
      _isPhoneVerified = user.phoneVerified;

      // Oturumu kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _currentUser = null;
      _isEmailVerified = false;
      _isPhoneVerified = false;
      
      // Oturumu sil
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      _clearError();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // ==================== DOĞRULAMA İŞLEMLERİ ====================

  /// Email doğrula
  Future<bool> verifyEmail(String code) async {
    try {
      _setLoading(true);
      _clearError();

      // Kod validasyonu
      final codeError = ValidationService.validateVerificationCode(code);
      if (codeError != null) {
        _setError(codeError);
        return false;
      }

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // Test amaçlı magic code: 123456
      if (code != '123456') {
        _setError('Hatalı doğrulama kodu. Test için: 123456');
        return false;
      }

      final user = await _authService.verifyEmail(_currentUser!.id);
      _currentUser = user;
      _isEmailVerified = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Telefon doğrula
  Future<bool> verifyPhone(String code) async {
    try {
      _setLoading(true);
      _clearError();

      // Kod validasyonu
      final codeError = ValidationService.validateVerificationCode(code);
      if (codeError != null) {
        _setError(codeError);
        return false;
      }

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // SMS doğrulaması geçici olarak devre dışı (Otomatik doğrula)
      final user = await _authService.verifyPhone(_currentUser!.id);
      _currentUser = user;
      _isPhoneVerified = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Email doğrulama kodu gönder
  Future<bool> sendEmailVerificationCode() async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // TODO: Email servisi ile kod gönder
      // Şimdilik başarılı kabul ediliyor
      await Future.delayed(const Duration(seconds: 1));

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// SMS doğrulama kodu gönder
  Future<bool> sendPhoneVerificationCode() async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // TODO: SMS servisi ile kod gönder
      // Şimdilik başarılı kabul ediliyor
      await Future.delayed(const Duration(seconds: 1));

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== ŞİFRE İŞLEMLERİ ====================

  /// Şifre değiştir
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // Validasyon
      final passwordError = ValidationService.validatePassword(newPassword);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final matchError = ValidationService.validatePasswordMatch(
        newPassword,
        confirmPassword,
      );
      if (matchError != null) {
        _setError(matchError);
        return false;
      }

      await _authService.changePassword(
        userId: _currentUser!.id,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Şifre sıfırla (email/SMS ile)
  Future<bool> resetPassword({
    required String emailOrPhone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validasyon
      final passwordError = ValidationService.validatePassword(newPassword);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final matchError = ValidationService.validatePasswordMatch(
        newPassword,
        confirmPassword,
      );
      if (matchError != null) {
        _setError(matchError);
        return false;
      }

      // Email mi telefon mu kontrol et
      String resetValue = emailOrPhone.trim();
      if (emailOrPhone.contains('@')) {
        resetValue = emailOrPhone.toLowerCase();
      } else {
        resetValue = ValidationService.normalizePhone(emailOrPhone);
      }

      await _authService.resetPassword(
        emailOrPhone: resetValue,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== PROFİL İŞLEMLERİ ====================

  /// Profil güncelle
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      // Validasyon
      if (name != null) {
        final nameError = ValidationService.validateName(name);
        if (nameError != null) {
          _setError(nameError);
          return false;
        }
      }

      if (email != null) {
        final emailError = ValidationService.validateEmail(email);
        if (emailError != null) {
          _setError(emailError);
          return false;
        }
      }

      if (phone != null) {
        final phoneError = ValidationService.validatePhone(phone);
        if (phoneError != null) {
          _setError(phoneError);
          return false;
        }
      }

      final normalizedPhone = phone != null
          ? ValidationService.normalizePhone(phone)
          : null;

      final user = await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name?.trim(),
        email: email?.trim().toLowerCase(),
        phone: normalizedPhone,
      );

      _currentUser = user;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Hesabı sil
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        _setError('Kullanıcı bulunamadı');
        return false;
      }

      await _authService.deleteAccount(_currentUser!.id);
      _currentUser = null;
      _isEmailVerified = false;
      _isPhoneVerified = false;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== OTURUM YÖNETİMİ ====================

  /// Oturumu yükle (uygulama başlangıcında)
  Future<void> loadSession(String userId) async {
    try {
      _setLoading(true);
      await _authService.loadSession(userId);
      _currentUser = _authService.currentUser;
      
      if (_currentUser != null) {
        _isEmailVerified = _currentUser!.emailVerified;
        _isPhoneVerified = _currentUser!.phoneVerified;
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  /// Oturumu kontrol et (SharedPreferences'tan)
  Future<bool> checkSession() async {
    try {
      _setLoading(true);
      
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        await loadSession(userId);
        _setLoading(false);
        return _currentUser != null;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Yüklenme durumunu ayarla
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Hata mesajını ayarla
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Hatayı temizle
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Hatayı manuel temizle (UI'dan)
  void clearError() {
    _clearError();
  }
}
