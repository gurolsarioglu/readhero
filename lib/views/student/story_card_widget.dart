import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';

/// Hikaye kartı widget'ı
/// Kütüphane ekranında hikayeleri gösterir
class StoryCardWidget extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final VoidCallback? onOfflineToggle;

  const StoryCardWidget({
    super.key,
    required this.story,
    required this.onTap,
    this.onOfflineToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Kategori ve offline badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      story.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Offline badge
                  if (story.isOffline)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.offline_pin,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      story.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // İçerik önizleme
                    Expanded(
                      child: Text(
                        story.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Alt bilgiler
                    Row(
                      children: [
                        // Sınıf seviyesi
                        _buildInfoChip(
                          '${story.gradeLevel}. Sınıf',
                          Icons.school,
                          AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        // Kelime sayısı
                        _buildInfoChip(
                          '${story.wordCount} kelime',
                          Icons.text_fields,
                          AppTheme.accentColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Zorluk seviyesi
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: _getDifficultyColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          story.difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(),
                          ),
                        ),
                        const Spacer(),
                        // Tahmini okuma süresi
                        Text(
                          '~${story.estimatedReadingTime} dk',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    // Kategoriye göre renk döndür
    switch (story.category) {
      case 'Macera':
        return const Color(0xFFFF6B6B);
      case 'Hayvanlar':
        return const Color(0xFF4ECDC4);
      case 'Bilim':
        return const Color(0xFF45B7D1);
      case 'Dostluk':
        return const Color(0xFFFFA07A);
      case 'Doğa':
        return const Color(0xFF98D8C8);
      case 'Aile':
        return const Color(0xFFF7B731);
      case 'Okul':
        return const Color(0xFF5F27CD);
      case 'Fantastik':
        return const Color(0xFFEE5A6F);
      case 'Tarih':
        return const Color(0xFF95A5A6);
      case 'Spor':
        return const Color(0xFF00B894);
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getDifficultyColor() {
    switch (story.difficulty) {
      case 'kolay':
        return AppTheme.secondaryColor;
      case 'orta':
        return AppTheme.accentColor;
      case 'zor':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
