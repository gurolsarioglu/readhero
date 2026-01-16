# Android Derleme Hataları ve Çözüm Kayıtları - 15.01.2026

Bu belgede, ReadHero Android derleme sürecinde karşılaşılan hatalar ve uygulanan çözümler kaydedilmiştir.

## 1. UI ve Widget Hataları

### GradientBackground Hataları
- **Hata:** `colors` parametresinin eksik olması.
- **Çözüm:** `quiz_view.dart`, `quiz_intro_view.dart` ve `quiz_result_view.dart` dosyalarında `GradientBackground` widget'ına `colors` parametresi eklendi.

### CustomButton Hataları
- **Hata:** `onPressed` parametresinin zorunlu ve non-nullable olması butonun devre dışı bırakılmasını engelliyordu.
- **Çözüm:** `custom_button.dart` içinde `onPressed` nullable yapıldı ve butonun `onPressed` mantığı `(isLoading || onPressed == null) ? null : onPressed` şeklinde güncellendi.
- **Hata:** `quiz_result_view.dart` içinde olmayan `isPrimary` parametresinin kullanımı.
- **Çözüm:** `isPrimary` kaldırıldı, yerine başarı durumuna göre `backgroundColor: widget.result.isPassed ? AppTheme.primaryColor : Colors.grey` eklendi.

### Dinamik Renk ve "const" Hataları
- **Hata:** `AppTheme` içindeki renkler derleme zamanı sabiti olmadığı için `const` widget'larda kullanımı hata veriyordu.
- **Çözüm:** Aşağıdaki dosyalarda `AppTheme` renklerini kullanan `Text`, `Icon`, `TextStyle`, `SnackBar` ve `AlwaysStoppedAnimation` widget'larından `const` anahtar kelimesi kaldırıldı:
  - `onboarding_view.dart`
  - `story_detail_view.dart`
  - `reading_view.dart`
  - `splash_view.dart`
  - `login_view.dart`
  - `register_view.dart`
  - `verification_view.dart`
  - `library_view.dart`
  - `select_student_view.dart`
  - `ai_test_view.dart`

## 2. Controller ve Mantıksal Hatalar

### QuizController Hataları
- **Hata:** `startQuiz` ve `finishQuiz` metodlarının `sessionId` parametresini almaması/işlememesi.
- **Çözüm:** Metod imzaları güncellendi, `sessionId` takibi eklendi ve timer dolduğunda otomatik bitirme mantığına `sessionId` eklendi.
- **Hata:** `QuizResultModel` oluşturulurken eksik zorunlu alanlar (`studentId`, `correctCount`, `totalQuestions`).
- **Çözüm:** Model oluşturma sırasında veritabanından `studentId` çekildi ve tüm alanlar dolduruldu. `answers` listesi dönüşümü (`Map` -> `List`) düzeltildi.
- **Hata:** Tip uyuşmazlığı (`score` double/int ve `wpm` null safety).
- **Çözüm:** `score.toInt()` dönüşümü ve `session.wpm ?? 0.0` kontrolü eklendi.

### ReadingController Hataları
- **Hata:** `ReadingSessionModel` üzerinde `wordsPerMinute` diye bir alanın olmaması.
- **Çözüm:** `session.wpm?.round()` kullanımı ile değiştirildi.

### StoryController Hataları
- **Hata:** `toggleOffline` metodunda manuel model oluşturulurken `updatedAt` gibi zorunlu alanların eksik kalması.
- **Çözüm:** `story.copyWith` metoduna geçildi ve `updatedAt` eklendi.

## 3. Sistem ve Bağımlılık Hataları

### Paket Sürüm Sorunları
- **Hata:** `record_linux` paketinin `RecordLinux` sınıfını tam implemente etmemesi nedeniyle oluşan Gradle hatası.
- **Çözüm:** `record` paketi `pubspec.yaml` üzerinde `^6.1.2` sürümüne yükseltildi.

### Gradle ve Önbellek Hataları
- **Hata:** Farklı sürücüler arası (C: ve Y:) Kotlin derleme önbelleği uyumsuzlukları.
- **Çözüm:** `flutter clean` komutu çalıştırılarak tüm yapılar temizlendi ve yeniden derlendi.

---
**Sonuç:** Uygulama başarıyla derlendi ve Android cihazda çalışır duruma getirildi.
