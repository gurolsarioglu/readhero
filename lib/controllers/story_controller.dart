import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/story_service.dart';
import '../services/ai_all_in_one.dart';
import '../core/constants/ai_prompts.dart';
import '../database/database_seeder.dart';

/// Hikaye controller - Hikaye yönetimi için state management
class StoryController extends ChangeNotifier {
  final StoryService _storyService = StoryService();
  final AIService _aiService = AIService();

  // ==================== STATE ====================

  List<StoryModel> _stories = [];
  List<StoryModel> _filteredStories = [];
  StoryModel? _selectedStory;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtre durumu
  int? _selectedGradeLevel;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String _searchQuery = '';
  bool _showOnlyOffline = false;

  // ==================== GETTERS ====================

  /// Tüm hikayeler
  List<StoryModel> get stories => _stories;

  /// Filtrelenmiş hikayeler
  List<StoryModel> get filteredStories => _filteredStories;

  /// Seçili hikaye
  StoryModel? get selectedStory => _selectedStory;

  /// Yüklenme durumu
  bool get isLoading => _isLoading;

  /// Hata mesajı
  String? get errorMessage => _errorMessage;

  /// Seçili sınıf seviyesi
  int? get selectedGradeLevel => _selectedGradeLevel;

  /// Seçili kategori
  String? get selectedCategory => _selectedCategory;

  /// Seçili zorluk
  String? get selectedDifficulty => _selectedDifficulty;

  /// Arama sorgusu
  String get searchQuery => _searchQuery;

  /// Sadece offline göster
  bool get showOnlyOffline => _showOnlyOffline;

  /// Hikaye var mı?
  bool get hasStories => _stories.isNotEmpty;

  /// Filtrelenmiş hikaye var mı?
  bool get hasFilteredStories => _filteredStories.isNotEmpty;

  /// Kategoriler
  List<String> get categories => AIPrompts.storyCategories;

  /// Zorluk seviyeleri
  List<String> get difficulties => ['kolay', 'orta', 'zor'];

  // ==================== HİKAYE YÜKLEME ====================

  /// Tüm hikayeleri yükle
  Future<void> loadStories() async {
    try {
      _setLoading(true);
      _clearError();

      _stories = await _storyService.getAllStories();
      
      // Eğer hikaye yoksa seeder'ı çalıştır
      if (_stories.isEmpty) {
        await DatabaseSeeder.seedDatabase();
        _stories = await _storyService.getAllStories();
      }
      
      _applyFilters();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  /// Sınıf seviyesine göre yükle
  Future<void> loadStoriesByGrade(int gradeLevel) async {
    try {
      _setLoading(true);
      _clearError();

      _stories = await _storyService.getStoriesByGrade(gradeLevel);
      _applyFilters();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  /// Kategoriye göre yükle
  Future<void> loadStoriesByCategory(String category) async {
    try {
      _setLoading(true);
      _clearError();

      _stories = await _storyService.getStoriesByCategory(category);
      _applyFilters();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  /// Offline hikayeleri yükle
  Future<void> loadOfflineStories() async {
    try {
      _setLoading(true);
      _clearError();

      _stories = await _storyService.getOfflineStories();
      _applyFilters();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  // ==================== HİKAYE İŞLEMLERİ ====================

  /// Hikaye kaydet
  Future<bool> saveStory(StoryModel story) async {
    try {
      _setLoading(true);
      _clearError();

      await _storyService.saveStory(story);
      _stories.add(story);
      _applyFilters();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Hikaye sil
  Future<bool> deleteStory(String storyId) async {
    try {
      _setLoading(true);
      _clearError();

      await _storyService.deleteStory(storyId);
      _stories.removeWhere((story) => story.id == storyId);
      _applyFilters();

      if (_selectedStory?.id == storyId) {
        _selectedStory = null;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Hikaye seç
  void selectStory(String storyId) {
    _selectedStory = _stories.firstWhere(
      (story) => story.id == storyId,
      orElse: () => throw Exception('Hikaye bulunamadı'),
    );
    notifyListeners();
  }

  /// Seçili hikayeyi temizle
  void clearSelectedStory() {
    _selectedStory = null;
    notifyListeners();
  }

  // ==================== FİLTRELEME ====================

  /// Sınıf seviyesi filtresi uygula
  void setGradeFilter(int? gradeLevel) {
    _selectedGradeLevel = gradeLevel;
    _applyFilters();
  }

  /// Kategori filtresi uygula
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Zorluk filtresi uygula
  void setDifficultyFilter(String? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  /// Offline filtresi uygula
  void setOfflineFilter(bool showOnlyOffline) {
    _showOnlyOffline = showOnlyOffline;
    _applyFilters();
  }

  /// Tüm filtreleri temizle
  void clearFilters() {
    _selectedGradeLevel = null;
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = '';
    _showOnlyOffline = false;
    _applyFilters();
  }

  /// Filtreleri uygula
  void _applyFilters() {
    _filteredStories = _stories.where((story) {
      // Sınıf seviyesi filtresi
      if (_selectedGradeLevel != null && story.gradeLevel != _selectedGradeLevel) {
        return false;
      }

      // Kategori filtresi
      if (_selectedCategory != null && story.category != _selectedCategory) {
        return false;
      }

      // Zorluk filtresi
      if (_selectedDifficulty != null && story.difficulty != _selectedDifficulty) {
        return false;
      }

      // Offline filtresi
      if (_showOnlyOffline && !story.isOffline) {
        return false;
      }

      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = story.title.toLowerCase().contains(query);
        final keywordMatch = story.keywords.any(
          (keyword) => keyword.toLowerCase().contains(query),
        );
        if (!titleMatch && !keywordMatch) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // ==================== ARAMA ====================

  /// Hikaye ara
  void searchStories(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Aramayı temizle
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // ==================== AI İLE HİKAYE ÜRET ====================

  /// AI ile hikaye üret ve kaydet
  Future<StoryModel?> generateAndSaveStory({
    required int gradeLevel,
    required String category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // AI'yi başlat (gerekirse)
      if (!_aiService.isInitialized) {
        await _aiService.initialize();
      }

      // Hikaye üret
      final story = await _aiService.generateStory(
        gradeLevel: gradeLevel,
        category: category,
      );

      // Veritabanına kaydet
      await _storyService.saveStory(story);
      _stories.add(story);
      _applyFilters();

      _setLoading(false);
      return story;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return null;
    }
  }

  // ==================== OFFLINE YÖNETİMİ ====================

  /// Hikayeyi offline olarak işaretle
  Future<bool> toggleOffline(String storyId) async {
    try {
      final story = _stories.firstWhere((s) => s.id == storyId);
      final newOfflineStatus = !story.isOffline;

      await _storyService.markAsOffline(storyId, newOfflineStatus);

      // Listeyi güncelle
      final index = _stories.indexWhere((s) => s.id == storyId);
      if (index != -1) {
        _stories[index] = story.copyWith(
          isOffline: newOfflineStatus,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      _applyFilters();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ==================== İSTATİSTİKLER ====================

  /// Toplam hikaye sayısı
  int get totalStoryCount => _stories.length;

  /// Filtrelenmiş hikaye sayısı
  int get filteredStoryCount => _filteredStories.length;

  /// Offline hikaye sayısı
  int get offlineStoryCount => _stories.where((s) => s.isOffline).length;

  /// Sınıf seviyesine göre hikaye sayısı
  int getStoryCountByGrade(int gradeLevel) {
    return _stories.where((s) => s.gradeLevel == gradeLevel).length;
  }

  /// Kategoriye göre hikaye sayısı
  int getStoryCountByCategory(String category) {
    return _stories.where((s) => s.category == category).length;
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

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

  /// Controller'ı temizle
  @override
  void dispose() {
    _stories.clear();
    _filteredStories.clear();
    _selectedStory = null;
    super.dispose();
  }
}
