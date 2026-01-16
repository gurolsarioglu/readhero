# 🤖 GOOGLE GEMINI AI ENTEGRASYONU - PLAN

**Tarih:** 16 Ocak 2026, 11:45  
**Amaç:** Local LLM ile hikaye ve quiz otomatik üretimi

---

## 🎯 HEDEFLER

1. **Hikaye Üretimi**
   - Sınıf seviyesine uygun hikayeler
   - Kategori bazlı içerik
   - Zorluk seviyesi ayarlanabilir

2. **Quiz Otomatik Oluşturma**
   - Her okumada farklı sorular
   - 5 soru, 4 şık
   - Doğru cevap otomatik belirlenir

3. **Veritabanı Sorunu Çözümü**
   - Statik JSON yerine dinamik üretim
   - Her hikaye için quiz garantisi

---

## 📦 GEREKLİ PAKETLER

```yaml
# pubspec.yaml
dependencies:
  google_generative_ai: ^0.2.2  # Gemini AI SDK
  flutter_dotenv: ^5.1.0        # Zaten var
```

---

## 🔑 API KEY KURULUMU

```env
# .env dosyası
GEMINI_API_KEY=your_api_key_here
```

**API Key Alma:**
1. https://makersuite.google.com/app/apikey
2. "Create API Key" tıkla
3. Key'i kopyala ve .env'ye ekle

---

## 🏗️ MİMARİ

```
lib/
├── services/
│   ├── ai_service.dart          # Gemini AI wrapper
│   ├── story_generator.dart     # Hikaye üretimi
│   └── quiz_generator.dart      # Quiz üretimi
├── models/
│   ├── ai_story_request.dart    # İstek modeli
│   └── ai_quiz_request.dart     # Quiz isteği
└── views/
    └── student/
        └── generate_story_view.dart  # AI hikaye oluşturma UI
```

---

## 💻 KOD YAPISI

### 1. AI Service (Temel)

```dart
// lib/services/ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final AIService instance = AIService._();
  AIService._();
  
  late final GenerativeModel _model;
  
  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }
  
  Future<String> generateText(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? '';
  }
}
```

### 2. Story Generator

```dart
// lib/services/story_generator.dart
class StoryGenerator {
  final AIService _ai = AIService.instance;
  
  Future<StoryModel> generateStory({
    required int gradeLevel,
    required String category,
    required String difficulty,
  }) async {
    final prompt = '''
Türkçe bir çocuk hikayesi oluştur:
- Sınıf Seviyesi: $gradeLevel
- Kategori: $category
- Zorluk: $difficulty
- Kelime Sayısı: ${_getWordCount(gradeLevel)}

Hikaye JSON formatında olmalı:
{
  "title": "Hikaye Başlığı",
  "content": "Hikaye metni...",
  "keywords": ["anahtar", "kelimeler"]
}
''';
    
    final response = await _ai.generateText(prompt);
    return _parseStoryResponse(response, gradeLevel, category);
  }
  
  int _getWordCount(int grade) {
    switch (grade) {
      case 1: return 150;
      case 2: return 250;
      case 3: return 350;
      case 4: return 500;
      default: return 250;
    }
  }
}
```

### 3. Quiz Generator

```dart
// lib/services/quiz_generator.dart
class QuizGenerator {
  final AIService _ai = AIService.instance;
  
  Future<QuizModel> generateQuiz({
    required String storyId,
    required String storyTitle,
    required String storyContent,
  }) async {
    final prompt = '''
Aşağıdaki hikaye için 5 adet çoktan seçmeli soru oluştur:

Hikaye: $storyTitle
İçerik: $storyContent

Her soru için:
- 1 soru metni
- 4 şık (A, B, C, D)
- 1 doğru cevap (0-3 arası index)

JSON formatında döndür:
{
  "questions": [
    {
      "question": "Soru metni?",
      "options": ["Şık A", "Şık B", "Şık C", "Şık D"],
      "correctAnswer": 0
    }
  ]
}
''';
    
    final response = await _ai.generateText(prompt);
    return _parseQuizResponse(response, storyId);
  }
}
```

---

## 🎨 UI FLOW

### Hikaye Oluşturma Ekranı

```
┌─────────────────────────────┐
│  AI ile Hikaye Oluştur      │
├─────────────────────────────┤
│                             │
│  Sınıf Seviyesi: [1-4]     │
│  Kategori: [Dropdown]       │
│  Zorluk: [Kolay/Orta/Zor]  │
│                             │
│  [🤖 Hikaye Oluştur]        │
│                             │
│  ⏳ Oluşturuluyor...        │
│  (Progress indicator)       │
│                             │
└─────────────────────────────┘
```

---

## ⚡ HIZLI ENTEGRASYON ADIMLARI

### Adım 1: Paket Kurulumu
```bash
flutter pub add google_generative_ai
```

### Adım 2: API Key Ekleme
```env
GEMINI_API_KEY=AIza...
```

### Adım 3: Service Oluşturma
- ai_service.dart
- story_generator.dart
- quiz_generator.dart

### Adım 4: UI Ekleme
- generate_story_view.dart

### Adım 5: Integration
- Library view'a "AI ile Üret" butonu ekle
- Story detail'de "Quiz Oluştur" butonu

---

## 🧪 TEST SENARYOSU

1. **Hikaye Üretimi**
   ```
   Sınıf: 1
   Kategori: Macera
   Zorluk: Kolay
   → Hikaye oluşturuldu ✅
   ```

2. **Quiz Üretimi**
   ```
   Hikaye okundu
   → Quiz otomatik oluşturuldu ✅
   → 5 soru, 4 şık ✅
   ```

3. **Farklı Sorular**
   ```
   Aynı hikaye 2. kez okundu
   → Farklı sorular geldi ✅
   ```

---

## 📊 AVANTAJLAR

✅ **Sınırsız İçerik** - JSON sınırlaması yok  
✅ **Dinamik Sorular** - Her seferinde farklı  
✅ **Veritabanı Sorunu Çözümü** - Quiz garantisi  
✅ **Özelleştirilebilir** - Sınıf/kategori/zorluk  
✅ **Offline Desteği** - Cache mekanizması eklenebilir  

---

## ⚠️ DİKKAT EDİLECEKLER

1. **API Limitleri**
   - Gemini Pro: 60 request/minute
   - Cache kullan

2. **Hata Yönetimi**
   - Network hatası
   - API hatası
   - Parse hatası

3. **Maliyet**
   - Gemini Pro: Ücretsiz (limitli)
   - Production: Ücretli plan

---

## 🚀 BAŞLAYALIM MI?

Şimdi adım adım uygulayalım:

1. ✅ Sınıf filtreleme düzeltildi
2. ⏳ AI Service kurulumu
3. ⏳ Story Generator
4. ⏳ Quiz Generator
5. ⏳ UI Integration

**Hazır mısınız?** 🎯
