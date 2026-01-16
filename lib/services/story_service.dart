import '../database/database_helper.dart';
import '../models/models.dart';

/// Hikaye yönetim servisi
/// Hikayelerin veritabanı işlemlerini yönetir
class StoryService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Singleton instance
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  // ==================== CRUD İŞLEMLERİ ====================

  /// Hikaye kaydet
  Future<void> saveStory(StoryModel story) async {
    try {
      await _db.insert('stories', story.toMap());
    } catch (e) {
      throw Exception('Hikaye kaydetme hatası: $e');
    }
  }

  /// Hikayeleri toplu kaydet
  Future<void> saveStories(List<StoryModel> stories) async {
    try {
      for (final story in stories) {
        await saveStory(story);
      }
    } catch (e) {
      throw Exception('Hikayeleri kaydetme hatası: $e');
    }
  }

  /// Hikaye güncelle
  Future<void> updateStory(StoryModel story) async {
    try {
      await _db.update('stories', story.toMap(), story.id);
    } catch (e) {
      throw Exception('Hikaye güncelleme hatası: $e');
    }
  }

  /// Hikaye sil
  Future<void> deleteStory(String storyId) async {
    try {
      await _db.delete('stories', storyId);
    } catch (e) {
      throw Exception('Hikaye silme hatası: $e');
    }
  }

  /// ID'ye göre hikaye al
  Future<StoryModel?> getStoryById(String storyId) async {
    try {
      final storyMap = await _db.getById('stories', storyId);
      if (storyMap == null) return null;
      return StoryModel.fromMap(storyMap);
    } catch (e) {
      throw Exception('Hikaye alma hatası: $e');
    }
  }

  /// Tüm hikayeleri al
  Future<List<StoryModel>> getAllStories() async {
    try {
      final results = await _db.query('stories', orderBy: 'created_at DESC');
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Hikayeleri alma hatası: $e');
    }
  }

  // ==================== FİLTRELEME ====================

  /// Sınıf seviyesine göre hikayeleri al
  Future<List<StoryModel>> getStoriesByGrade(int gradeLevel) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'grade_level = ?',
        whereArgs: [gradeLevel],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Sınıf seviyesine göre hikaye alma hatası: $e');
    }
  }

  /// Kategoriye göre hikayeleri al
  Future<List<StoryModel>> getStoriesByCategory(String category) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Kategoriye göre hikaye alma hatası: $e');
    }
  }

  /// Zorluk seviyesine göre hikayeleri al
  Future<List<StoryModel>> getStoriesByDifficulty(String difficulty) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'difficulty = ?',
        whereArgs: [difficulty],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Zorluk seviyesine göre hikaye alma hatası: $e');
    }
  }

  /// Sınıf ve kategoriye göre hikayeleri al
  Future<List<StoryModel>> getStoriesByGradeAndCategory({
    required int gradeLevel,
    required String category,
  }) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'grade_level = ? AND category = ?',
        whereArgs: [gradeLevel, category],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Filtrelenmiş hikaye alma hatası: $e');
    }
  }

  /// Offline hikayeleri al
  Future<List<StoryModel>> getOfflineStories() async {
    try {
      final results = await _db.query(
        'stories',
        where: 'is_offline = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Offline hikaye alma hatası: $e');
    }
  }

  // ==================== ARAMA ====================

  /// Başlığa göre hikaye ara
  Future<List<StoryModel>> searchStoriesByTitle(String query) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => StoryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Hikaye arama hatası: $e');
    }
  }

  /// Anahtar kelimelere göre hikaye ara
  Future<List<StoryModel>> searchStoriesByKeywords(String query) async {
    try {
      // SQLite'da JSON array araması için basit bir çözüm
      final allStories = await getAllStories();
      return allStories.where((story) {
        return story.keywords.any(
          (keyword) => keyword.toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    } catch (e) {
      throw Exception('Anahtar kelime arama hatası: $e');
    }
  }

  // ==================== OFFLINE YÖNETİMİ ====================

  /// Hikayeyi offline olarak işaretle
  Future<void> markAsOffline(String storyId, bool isOffline) async {
    try {
      final story = await getStoryById(storyId);
      if (story == null) {
        throw Exception('Hikaye bulunamadı');
      }

      final updatedStory = StoryModel(
        id: story.id,
        title: story.title,
        content: story.content,
        category: story.category,
        gradeLevel: story.gradeLevel,
        wordCount: story.wordCount,
        difficulty: story.difficulty,
        keywords: story.keywords,
        isOffline: isOffline,
        createdAt: story.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await updateStory(updatedStory);
    } catch (e) {
      throw Exception('Offline işaretleme hatası: $e');
    }
  }

  // ==================== İSTATİSTİKLER ====================

  /// Toplam hikaye sayısı
  Future<int> getTotalStoryCount() async {
    try {
      final results = await _db.query('stories');
      return results.length;
    } catch (e) {
      throw Exception('Hikaye sayısı alma hatası: $e');
    }
  }

  /// Sınıf seviyesine göre hikaye sayısı
  Future<int> getStoryCountByGrade(int gradeLevel) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'grade_level = ?',
        whereArgs: [gradeLevel],
      );
      return results.length;
    } catch (e) {
      throw Exception('Sınıf hikaye sayısı alma hatası: $e');
    }
  }

  /// Kategoriye göre hikaye sayısı
  Future<int> getStoryCountByCategory(String category) async {
    try {
      final results = await _db.query(
        'stories',
        where: 'category = ?',
        whereArgs: [category],
      );
      return results.length;
    } catch (e) {
      throw Exception('Kategori hikaye sayısı alma hatası: $e');
    }
  }

  /// Offline hikaye sayısı
  Future<int> getOfflineStoryCount() async {
    try {
      final results = await _db.query(
        'stories',
        where: 'is_offline = ?',
        whereArgs: [1],
      );
      return results.length;
    } catch (e) {
      throw Exception('Offline hikaye sayısı alma hatası: $e');
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Veritabanını temizle (tüm hikayeleri sil)
  Future<void> clearAllStories() async {
    try {
      final stories = await getAllStories();
      for (final story in stories) {
        await deleteStory(story.id);
      }
    } catch (e) {
      throw Exception('Hikayeleri temizleme hatası: $e');
    }
  }

  /// Hikaye var mı kontrol et
  Future<bool> hasStories() async {
    try {
      final count = await getTotalStoryCount();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  /// Belirli bir hikaye var mı kontrol et
  Future<bool> storyExists(String storyId) async {
    try {
      final story = await getStoryById(storyId);
      return story != null;
    } catch (e) {
      return false;
    }
  }
}
