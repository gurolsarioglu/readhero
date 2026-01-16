/// Validasyon servisi
class ValidationService {
  /// Email validasyonu
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email adresi gerekli';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Geçersiz email adresi';
    }

    return null;
  }

  /// Telefon validasyonu (Türkiye)
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Telefon numarası gerekli';
    }

    // Sadece rakamları al
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Türkiye telefon formatı: 10 veya 12 haneli (90 ile başlıyorsa)
    if (digitsOnly.length == 10) {
      // 5XXXXXXXXX formatı
      if (!digitsOnly.startsWith('5')) {
        return 'Telefon numarası 5 ile başlamalı';
      }
      return null;
    } else if (digitsOnly.length == 12) {
      // 905XXXXXXXXX formatı
      if (!digitsOnly.startsWith('905')) {
        return 'Telefon numarası 905 ile başlamalı';
      }
      return null;
    }

    return 'Geçersiz telefon numarası (10 hane olmalı)';
  }

  /// Şifre validasyonu
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Şifre gerekli';
    }

    if (password.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }

    if (password.length > 50) {
      return 'Şifre en fazla 50 karakter olabilir';
    }

    return null;
  }

  /// Şifre eşleşme kontrolü
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }

    if (password != confirmPassword) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  /// İsim validasyonu
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'İsim gerekli';
    }

    if (name.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }

    if (name.length > 50) {
      return 'İsim en fazla 50 karakter olabilir';
    }

    // Sadece harf ve boşluk
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(name)) {
      return 'İsim sadece harf içerebilir';
    }

    return null;
  }

  /// Yaş validasyonu (18+)
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Doğum tarihi gerekli';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    // Doğum günü henüz gelmemişse yaşı 1 azalt
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      if (age - 1 < 18) {
        return 'En az 18 yaşında olmalısınız';
      }
    } else {
      if (age < 18) {
        return 'En az 18 yaşında olmalısınız';
      }
    }

    return null;
  }

  /// Doğrulama kodu validasyonu (6 haneli)
  static String? validateVerificationCode(String? code) {
    if (code == null || code.isEmpty) {
      return 'Doğrulama kodu gerekli';
    }

    if (code.length != 6) {
      return 'Doğrulama kodu 6 haneli olmalı';
    }

    final codeRegex = RegExp(r'^\d{6}$');
    if (!codeRegex.hasMatch(code)) {
      return 'Geçersiz doğrulama kodu';
    }

    return null;
  }

  /// Öğrenci adı validasyonu
  static String? validateStudentName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Öğrenci adı gerekli';
    }

    if (name.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }

    if (name.length > 30) {
      return 'İsim en fazla 30 karakter olabilir';
    }

    return null;
  }

  /// Sınıf seviyesi validasyonu (1-4)
  static String? validateGradeLevel(int? gradeLevel) {
    if (gradeLevel == null) {
      return 'Sınıf seviyesi gerekli';
    }

    if (gradeLevel < 1 || gradeLevel > 4) {
      return 'Sınıf seviyesi 1-4 arasında olmalı';
    }

    return null;
  }

  /// Telefon numarasını formatla (5XXXXXXXXX -> 0 (5XX) XXX XX XX)
  static String formatPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10) {
      return '0 (${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 8)} ${digitsOnly.substring(8)}';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('90')) {
      final localNumber = digitsOnly.substring(2);
      return '0 (${localNumber.substring(0, 3)}) ${localNumber.substring(3, 6)} ${localNumber.substring(6, 8)} ${localNumber.substring(8)}';
    }
    
    return phone;
  }

  /// Telefon numarasını normalize et (her format -> 5XXXXXXXXX)
  static String normalizePhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 10 && digitsOnly.startsWith('5')) {
      return digitsOnly;
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('05')) {
      return digitsOnly.substring(1);
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('905')) {
      return digitsOnly.substring(2);
    } else if (digitsOnly.length == 13 && digitsOnly.startsWith('+905')) {
      return digitsOnly.substring(3);
    }
    
    return phone;
  }
}
