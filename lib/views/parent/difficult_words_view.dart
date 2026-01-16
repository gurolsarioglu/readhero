import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/difficult_word.dart';

/// Zorlanılan kelimeler sayfası (Veli paneli)
/// Çocuğun işaretlediği kelimeleri görüntüleme ve takip etme
class DifficultWordsView extends StatefulWidget {
  final String studentId;

  const DifficultWordsView({
    super.key,
    required this.studentId,
  });

  @override
  State<DifficultWordsView> createState() => _DifficultWordsViewState();
}

class _DifficultWordsViewState extends State<DifficultWordsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<DifficultWord> _allWords = [];
  List<DifficultWord> _activeWords = [];
  List<DifficultWord> _learnedWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Kelimeleri yükle
  Future<void> _loadWords() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      
      final maps = await db.query(
        'difficult_words',
        where: 'student_id = ?',
        whereArgs: [widget.studentId],
        orderBy: 'marked_at DESC',
      );

      _allWords = maps.map((map) => DifficultWord.fromMap(map)).toList();
      
      // Aktif ve öğrenilmiş kelimeleri ayır
      _activeWords = _allWords.where((w) => !w.isLearned).toList();
      _learnedWords = _allWords.where((w) => w.isLearned).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Kelimeler yüklenirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Kelimeyi öğrenildi olarak işaretle
  Future<void> _markAsLearned(DifficultWord word) async {
    try {
      final updatedWord = word.copyWith(
        isLearned: true,
        learnedAt: DateTime.now(),
      );

      final db = await DatabaseHelper.instance.database;
      await db.update(
        'difficult_words',
        updatedWord.toMap(),
        where: 'id = ?',
        whereArgs: [word.id],
      );

      await _loadWords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${word.word}" öğrenildi olarak işaretlendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Güncelleme hatası: $e');
    }
  }

  /// Kelimeyi tekrar çalış olarak işaretle
  Future<void> _incrementReviewCount(DifficultWord word) async {
    try {
      final updatedWord = word.copyWith(
        reviewCount: word.reviewCount + 1,
      );

      final db = await DatabaseHelper.instance.database;
      await db.update(
        'difficult_words',
        updatedWord.toMap(),
        where: 'id = ?',
        whereArgs: [word.id],
      );

      await _loadWords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${word.word}" tekrar edildi (${updatedWord.reviewCount}. kez)'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Güncelleme hatası: $e');
    }
  }

  /// Kelimeyi sil
  Future<void> _deleteWord(DifficultWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelimeyi Sil'),
        content: Text('"${word.word}" kelimesini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'difficult_words',
        where: 'id = ?',
        whereArgs: [word.id],
      );

      await _loadWords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kelime silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Defteri'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Çalışılacak (${_activeWords.length})',
              icon: const Icon(Icons.school),
            ),
            Tab(
              text: 'Öğrenildi (${_learnedWords.length})',
              icon: const Icon(Icons.check_circle),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWords,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildWordsList(_activeWords, isActive: true),
                _buildWordsList(_learnedWords, isActive: false),
              ],
            ),
    );
  }

  /// Kelime listesi
  Widget _buildWordsList(List<DifficultWord> words, {required bool isActive}) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.book : Icons.celebration,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'Henüz işaretlenmiş kelime yok'
                  : 'Henüz öğrenilmiş kelime yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Okuma sırasında bilinmeyen kelimeleri işaretleyin'
                  : 'Kelimeleri öğrendikçe buraya eklenecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        itemBuilder: (context, index) {
          return _buildWordCard(words[index], isActive: isActive);
        },
      ),
    );
  }

  /// Kelime kartı
  Widget _buildWordCard(DifficultWord word, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          child: Icon(
            isActive ? Icons.school : Icons.check_circle,
            color: isActive ? AppTheme.primaryColor : Colors.green,
          ),
        ),
        title: Text(
          word.word,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMMM yyyy', 'tr_TR').format(word.markedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (word.reviewCount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.refresh, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${word.reviewCount} kez tekrar edildi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anlam
                if (word.meaning != null) ...[
                  const Text(
                    'Anlam:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.meaning!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],

                // Örnek cümle
                if (word.exampleSentence != null) ...[
                  const Text(
                    'Örnek Cümle:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      word.exampleSentence!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Aksiyon butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Sil butonu
                    TextButton.icon(
                      onPressed: () => _deleteWord(word),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Sil'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    if (isActive) ...[
                      // Tekrar çalış butonu
                      TextButton.icon(
                        onPressed: () => _incrementReviewCount(word),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Çalıştım'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Öğrendim butonu
                      ElevatedButton.icon(
                        onPressed: () => _markAsLearned(word),
                        icon: const Icon(Icons.check),
                        label: const Text('Öğrendim'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
