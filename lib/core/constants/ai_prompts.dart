/// AI Prompt şablonları
/// Gemini AI için kullanılacak tüm promptlar
class AIPrompts {
  // ==================== HİKAYE ÜRETİMİ ====================

  /// Hikaye üretim prompt'u
  static String storyGenerationPrompt({
    required int gradeLevel,
    required String category,
    required int wordCount,
  }) {
    return '''
Sen bir çocuk edebiyatı yazarısın. ${gradeLevel}. sınıf seviyesindeki çocuklar için bir hikaye yazacaksın.

GEREKSINIMLER:
- Kategori: $category
- Sınıf Seviyesi: $gradeLevel
- Kelime Sayısı: $wordCount kelime (±10%)
- Dil: Türkçe
- Ton: Eğlenceli, öğretici, pozitif

SINIF SEVİYESİNE GÖRE KURALLAR:
${_getGradeLevelRules(gradeLevel)}

HİKAYE ÖZELLİKLERİ:
1. Başlık: Çekici ve merak uyandırıcı
2. Karakter: Ana karakter çocukların özdeşim kurabileceği biri olmalı
3. Olay Örgüsü: Basit, anlaşılır, mantıklı bir akış
4. Sonuç: Mutlu son veya öğretici bir mesaj
5. Dil: Sınıf seviyesine uygun kelimeler ve cümle yapıları
6. Ahlaki Değer: Dostluk, dürüstlük, cesaret gibi pozitif değerler

ÇIKTI FORMATI (JSON):
{
  "title": "Hikaye Başlığı",
  "content": "Hikaye metni buraya gelecek...",
  "category": "$category",
  "gradeLevel": $gradeLevel,
  "wordCount": kelime_sayısı,
  "difficulty": "kolay/orta/zor",
  "keywords": ["kelime1", "kelime2", "kelime3"],
  "moralLesson": "Hikayen in vermek istediği mesaj"
}

SADECE JSON formatında yanıt ver. Başka açıklama ekleme.
''';
  }

  /// Sınıf seviyesine göre kurallar
  static String _getGradeLevelRules(int gradeLevel) {
    switch (gradeLevel) {
      case 1:
        return '''
- Çok basit kelimeler kullan (günlük hayattan)
- Kısa cümleler (5-7 kelime)
- Tekrarlı yapılar kullan
- Görsel betimlemeler yap
- Sayılar ve renkler ekle
- Hayvan karakterler tercih et
''';
      case 2:
        return '''
- Basit kelimeler, az sayıda yeni kelime
- Orta uzunlukta cümleler (7-10 kelime)
- Basit bağlaçlar kullan (ve, ama, çünkü)
- Diyaloglar ekle
- Duygular ve hisler tanımla
- İnsan veya hayvan karakterler
''';
      case 3:
        return '''
- Orta seviye kelimeler, yeni kelimeler ekle
- Normal uzunlukta cümleler (10-12 kelime)
- Çeşitli bağlaçlar kullan
- Zengin diyaloglar
- Karakter gelişimi göster
- Sebep-sonuç ilişkileri kur
''';
      case 4:
        return '''
- Zengin kelime dağarcığı
- Uzun ve karmaşık cümleler (12-15 kelime)
- Yan cümleler kullan
- Detaylı betimlemeler
- Karakter derinliği
- Metaforlar ve benzetmeler
- Alt hikayeler ekle
''';
      default:
        return '- Sınıf seviyesine uygun içerik';
    }
  }

  // ==================== SINAV SORULARI ÜRETİMİ ====================

  /// Sınav soruları üretim prompt'u
  static String quizGenerationPrompt({
    required String storyTitle,
    required String storyContent,
    required int gradeLevel,
  }) {
    return '''
Aşağıdaki hikaye için okuduğunu anlama soruları hazırla.

HİKAYE BAŞLIĞI: $storyTitle
HİKAYE İÇERİĞİ:
$storyContent

GEREKSINIMLER:
- Toplam 5 soru
- Sınıf Seviyesi: $gradeLevel
- Her soru 3 şıklı (A, B, C)
- Dil: Türkçe

SORU DAĞILIMI:
1. Detay Sorusu 1: Hikayedeki spesifik bir bilgi (Kim? Ne? Nerede?)
2. Detay Sorusu 2: Hikayedeki başka bir spesifik bilgi
3. Anlam Çıkarma 1: Karakterin duyguları veya motivasyonu
4. Anlam Çıkarma 2: Olay örgüsü veya sebep-sonuç ilişkisi
5. Genel Değerlendirme: Hikayenin ana mesajı veya sonucu

HER SORU İÇİN:
- Soru metni açık ve anlaşılır olmalı
- 3 şık olmalı (A, B, C)
- Sadece 1 doğru cevap
- Yanlış şıklar mantıklı ama yanlış olmalı
- Doğru cevap için kısa açıklama ekle

ÇIKTI FORMATI (JSON):
{
  "storyId": "auto-generated",
  "questions": [
    {
      "question": "Soru metni?",
      "options": ["A) Şık 1", "B) Şık 2", "C) Şık 3"],
      "correctAnswer": 0,
      "explanation": "Doğru cevap açıklaması",
      "difficulty": "kolay/orta/zor",
      "type": "detail/inference/evaluation"
    }
  ]
}

SADECE JSON formatında yanıt ver. Başka açıklama ekleme.
''';
  }

  // ==================== KELİME AÇIKLAMASI ====================

  /// Kelime açıklama prompt'u
  static String wordExplanationPrompt({
    required String word,
    required String context,
    required int gradeLevel,
  }) {
    return '''
Aşağıdaki kelimeyi $gradeLevel. sınıf seviyesindeki bir çocuğa açıkla.

KELİME: $word
BAĞLAM: "$context"

GEREKSINIMLER:
- Basit ve anlaşılır dil kullan
- Örneklerle açıkla
- Sınıf seviyesine uygun kelimelerle tanımla
- Günlük hayattan örnekler ver

ÇIKTI FORMATI (JSON):
{
  "word": "$word",
  "definition": "Basit tanım",
  "example": "Örnek cümle",
  "synonyms": ["eş anlamlı 1", "eş anlamlı 2"],
  "antonyms": ["zıt anlamlı 1", "zıt anlamlı 2"]
}

SADECE JSON formatında yanıt ver. Başka açıklama ekleme.
''';
  }

  // ==================== DİLBİLGİSİ KONTROLÜ (BONUS) ====================

  /// Dilbilgisi kontrolü prompt'u
  static String grammarCheckPrompt({
    required String text,
  }) {
    return '''
Aşağıdaki metni dilbilgisi açısından kontrol et ve düzelt.

METİN:
$text

GEREKSINIMLER:
- Yazım hatalarını düzelt
- Noktalama işaretlerini kontrol et
- Cümle yapılarını düzelt
- Türkçe dil kurallarına uy

ÇIKTI FORMATI (JSON):
{
  "originalText": "$text",
  "correctedText": "Düzeltilmiş metin",
  "errors": [
    {
      "type": "yazım/noktalama/gramer",
      "original": "Hatalı kısım",
      "corrected": "Düzeltilmiş hali",
      "explanation": "Açıklama"
    }
  ],
  "errorCount": hata_sayısı
}

SADECE JSON formatında yanıt ver. Başka açıklama ekleme.
''';
  }

  // ==================== KATEGORİLER ====================

  /// Hikaye kategorileri
  static const List<String> storyCategories = [
    'Macera',
    'Hayvanlar',
    'Bilim',
    'Dostluk',
    'Doğa',
    'Aile',
    'Okul',
    'Fantastik',
    'Tarih',
    'Spor',
  ];

  /// Kategori açıklamaları
  static const Map<String, String> categoryDescriptions = {
    'Macera': 'Heyecan verici keşif ve serüven hikayeleri',
    'Hayvanlar': 'Hayvanların başından geçen eğlenceli olaylar',
    'Bilim': 'Bilimsel konuları eğlenceli anlatan hikayeler',
    'Dostluk': 'Arkadaşlık ve dostluk değerlerini anlatan hikayeler',
    'Doğa': 'Doğa, çevre ve hayvanlar hakkında öğretici hikayeler',
    'Aile': 'Aile değerleri ve sevgiyi anlatan hikayeler',
    'Okul': 'Okul hayatı ve öğrenme maceralarını anlatan hikayeler',
    'Fantastik': 'Hayal gücünü geliştiren sihirli hikayeler',
    'Tarih': 'Tarihi olayları çocuklara anlatan hikayeler',
    'Spor': 'Spor ve takım çalışmasını anlatan hikayeler',
  };

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Sınıf seviyesine göre kelime sayısı aralığı
  static Map<String, int> getWordCountRange(int gradeLevel) {
    switch (gradeLevel) {
      case 1:
        return {'min': 50, 'max': 100, 'target': 75};
      case 2:
        return {'min': 100, 'max': 200, 'target': 150};
      case 3:
        return {'min': 200, 'max': 300, 'target': 250};
      case 4:
        return {'min': 300, 'max': 500, 'target': 400};
      default:
        return {'min': 100, 'max': 200, 'target': 150};
    }
  }

  /// Zorluk seviyesi belirleme
  static String getDifficultyLevel(int gradeLevel, int wordCount) {
    final range = getWordCountRange(gradeLevel);
    final target = range['target']!;

    if (wordCount < target * 0.8) {
      return 'kolay';
    } else if (wordCount > target * 1.2) {
      return 'zor';
    } else {
      return 'orta';
    }
  }
}
