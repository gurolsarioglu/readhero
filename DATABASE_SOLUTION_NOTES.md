# 📝 VERİTABANI SORUNU - KALICI ÇÖZÜM NOTU

**Tarih:** 16 Ocak 2026, 11:38  
**Sorun:** Quiz verileri yükleme sorunu  
**Durum:** Geçici çözüm uygulandı, kalıcı çözüm planlandı

---

## 🔴 SORUN

Quiz veritabanı yükleme ve senkronizasyon sorunları:

1. **Quiz Yükleme Hatası**
   - Bazı hikayelerin quiz'leri veritabanına yüklenmiyor
   - "Hikaye bulunamadı" hatası alınıyor

2. **Veri Tutarsızlığı**
   - JSON'da quiz var ama veritabanında yok
   - Seed işlemi her zaman çalışmıyor

---

## ⚡ GEÇİCİ ÇÖZÜM (Uygulandı)

```bash
# Uygulamayı yeniden başlat
flutter run -d emulator-5554
```

Uygulama her başlatıldığında veritabanı kontrol edilip gerekirse seed ediliyor.

---

## 🔧 KALICI ÇÖZÜM ÖNERİLERİ

### 1. Veritabanı Migrasyon Sistemi

```dart
// lib/database/database_migrations.dart
class DatabaseMigrations {
  static const int currentVersion = 2;
  
  static Future<void> migrate(int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Quiz tablolarını yeniden oluştur
      await _recreateQuizTables();
      await _reseedQuizData();
    }
  }
  
  static Future<void> _recreateQuizTables() async {
    final db = DatabaseHelper.instance;
    await db.execute('DROP TABLE IF EXISTS quizzes');
    await db.execute('DROP TABLE IF EXISTS quiz_results');
    // Tabloları yeniden oluştur
  }
  
  static Future<void> _reseedQuizData() async {
    await DatabaseSeeder.seedDatabase();
  }
}
```

### 2. Veri Doğrulama Sistemi

```dart
// lib/database/database_validator.dart
class DatabaseValidator {
  static Future<bool> validateQuizData() async {
    final db = DatabaseHelper.instance;
    
    // Tüm hikayeleri al
    final stories = await db.getAllStories();
    
    // Her hikaye için quiz kontrolü
    for (var story in stories) {
      final quiz = await db.getQuizByStoryId(story.id);
      if (quiz == null) {
        print('⚠️ Quiz eksik: ${story.title} (${story.id})');
        return false;
      }
    }
    
    return true;
  }
  
  static Future<void> fixMissingQuizzes() async {
    // Eksik quiz'leri JSON'dan yükle
    await DatabaseSeeder.seedDatabase();
  }
}
```

### 3. Otomatik Onarım Mekanizması

```dart
// lib/controllers/story_controller.dart
Future<void> loadStories() async {
  try {
    // Hikayeleri yükle
    final stories = await _storyService.getAllStories();
    
    // Quiz kontrolü
    for (var story in stories) {
      final quiz = await _db.getQuizByStoryId(story.id);
      if (quiz == null) {
        print('⚠️ Quiz eksik, otomatik düzeltiliyor: ${story.id}');
        await _autoFixQuiz(story.id);
      }
    }
    
    _stories = stories;
    notifyListeners();
  } catch (e) {
    print('Hata: $e');
  }
}

Future<void> _autoFixQuiz(String storyId) async {
  // JSON'dan quiz'i bul ve yükle
  // Veya AI ile otomatik quiz oluştur
}
```

### 4. Veritabanı Sağlık Kontrolü

```dart
// lib/services/database_health_service.dart
class DatabaseHealthService {
  static Future<Map<String, dynamic>> checkHealth() async {
    final db = DatabaseHelper.instance;
    
    final storyCount = await db.count('stories');
    final quizCount = await db.count('quizzes');
    final studentCount = await db.count('students');
    
    final isHealthy = storyCount > 0 && quizCount > 0;
    
    return {
      'healthy': isHealthy,
      'stories': storyCount,
      'quizzes': quizCount,
      'students': studentCount,
      'issues': isHealthy ? [] : ['Quiz verileri eksik'],
    };
  }
  
  static Future<void> repair() async {
    print('🔧 Veritabanı onarılıyor...');
    await DatabaseSeeder.seedDatabase();
    print('✅ Onarım tamamlandı');
  }
}
```

### 5. Splash Screen'de Kontrol

```dart
// lib/views/auth/splash_view.dart
@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  // Veritabanı sağlık kontrolü
  final health = await DatabaseHealthService.checkHealth();
  
  if (!health['healthy']) {
    print('⚠️ Veritabanı sağlıksız, onarılıyor...');
    await DatabaseHealthService.repair();
  }
  
  // Normal başlatma devam eder
  await Future.delayed(const Duration(seconds: 2));
  _navigateToNext();
}
```

---

## 📋 YAPILACAKLAR

- [ ] Database migration sistemi ekle
- [ ] Veri doğrulama servisi oluştur
- [ ] Otomatik onarım mekanizması ekle
- [ ] Sağlık kontrolü servisi yaz
- [ ] Splash screen'e kontrol ekle
- [ ] Unit testler yaz
- [ ] Integration testler güncelle

---

## 🎯 ÖNCELİK

**Yüksek** - Bu sorun kullanıcı deneyimini doğrudan etkiliyor.

**Tahmini Süre:** 2-3 saat

---

## 💡 EK ÖNERİLER

1. **Logging Sistemi**
   - Tüm veritabanı işlemlerini logla
   - Hata raporlama sistemi ekle

2. **Offline-First Yaklaşım**
   - Tüm veriler local'de olmalı
   - Senkronizasyon opsiyonel

3. **Backup Mekanizması**
   - Kullanıcı verilerini düzenli yedekle
   - Geri yükleme özelliği ekle

---

**Not:** Kullanıcı testlere devam ediyor, bu notları sonra anlatacak.

**Hazırlayan:** Antigravity AI
