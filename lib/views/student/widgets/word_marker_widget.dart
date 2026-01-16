import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database_helper.dart';
import '../../../models/difficult_word.dart';
import '../../../services/ai_all_in_one.dart';

/// Kelime işaretleme widget'ı
/// Okuma sırasında bilinmeyen kelimeleri işaretleme
class WordMarkerWidget extends StatefulWidget {
  final String studentId;
  final String storyId;
  final String selectedWord;
  final VoidCallback? onWordMarked;

  const WordMarkerWidget({
    super.key,
    required this.studentId,
    required this.storyId,
    required this.selectedWord,
    this.onWordMarked,
  });

  @override
  State<WordMarkerWidget> createState() => _WordMarkerWidgetState();
}

class _WordMarkerWidgetState extends State<WordMarkerWidget> {
  final _aiService = AIService();
  bool _isLoading = false;
  String? _meaning;
  String? _exampleSentence;

  @override
  void initState() {
    super.initState();
    _fetchWordMeaning();
  }

  /// Kelime anlamını getir (AI ile)
  Future<void> _fetchWordMeaning() async {
    setState(() => _isLoading = true);

    try {
      final result = await _aiService.explainWord(widget.selectedWord);
      
      // Basit parse (AI'dan gelen yanıtı parse et)
      // Format: "Anlam: ... Örnek: ..."
      final parts = result.split('Örnek:');
      
      setState(() {
        _meaning = parts[0].replaceAll('Anlam:', '').trim();
        _exampleSentence = parts.length > 1 ? parts[1].trim() : null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Kelime anlamı getirme hatası: $e');
      setState(() {
        _meaning = 'Anlam yüklenemedi';
        _isLoading = false;
      });
    }
  }

  /// Kelimeyi kaydet
  Future<void> _saveWord() async {
    try {
      final word = DifficultWord(
        id: const Uuid().v4(),
        studentId: widget.studentId,
        storyId: widget.storyId,
        word: widget.selectedWord,
        meaning: _meaning,
        exampleSentence: _exampleSentence,
        markedAt: DateTime.now(),
      );

      final db = await DatabaseHelper.instance.database;
      await db.insert('difficult_words', word.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${widget.selectedWord}" kelime defterine eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onWordMarked?.call();
      }
    } catch (e) {
      debugPrint('Kelime kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.bookmark_add,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedWord,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Anlam
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
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
                _meaning ?? 'Anlam bulunamadı',
                style: const TextStyle(fontSize: 16),
              ),
              
              if (_exampleSentence != null) ...[
                const SizedBox(height: 16),
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
                    _exampleSentence!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveWord,
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Kelime Defterine Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
