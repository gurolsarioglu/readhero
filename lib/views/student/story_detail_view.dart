import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Hikaye detay ekranı
class StoryDetailView extends StatelessWidget {
  const StoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StoryController>(
        builder: (context, storyController, child) {
          final story = storyController.selectedStory;

          if (story == null) {
            return const Center(
              child: Text('Hikaye bulunamadı'),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _getCategoryColor(story.category),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    story.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor(story.category),
                          _getCategoryColor(story.category).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(story.category),
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Offline toggle
                  IconButton(
                    icon: Icon(
                      story.isOffline ? Icons.offline_pin : Icons.cloud_download,
                    ),
                    onPressed: () {
                      storyController.toggleOffline(story.id);
                    },
                    tooltip: story.isOffline
                        ? 'Offline\'dan kaldır'
                        : 'Offline\'a kaydet',
                  ),
                ],
              ),

              // İçerik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta bilgiler
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildInfoChip(
                            '${story.gradeLevel}. Sınıf',
                            Icons.school,
                            AppTheme.primaryColor,
                          ),
                          _buildInfoChip(
                            story.category,
                            Icons.category,
                            _getCategoryColor(story.category),
                          ),
                          _buildInfoChip(
                            '${story.wordCount} kelime',
                            Icons.text_fields,
                            AppTheme.accentColor,
                          ),
                          _buildInfoChip(
                            story.difficulty.toUpperCase(),
                            Icons.signal_cellular_alt,
                            _getDifficultyColor(story.difficulty),
                          ),
                          _buildInfoChip(
                            '~${story.estimatedReadingTime} dk',
                            Icons.access_time,
                            AppTheme.secondaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Hikaye içeriği
                      const Text(
                        'Hikaye',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        story.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Anahtar kelimeler
                      if (story.keywords.isNotEmpty) ...[
                        const Text(
                          'Anahtar Kelimeler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: story.keywords
                              .map((keyword) => Chip(
                                    label: Text(keyword),
                                    backgroundColor: AppTheme.primaryColor
                                        .withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // İstatistikler (placeholder)
                      CustomCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İstatistikler',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Okunma',
                                    '0',
                                    Icons.visibility,
                                  ),
                                  _buildStatItem(
                                    'Tamamlama',
                                    '%0',
                                    Icons.check_circle,
                                  ),
                                  _buildStatItem(
                                    'Ortalama WPM',
                                    '-',
                                    Icons.speed,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Buton için boşluk
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Okumaya başla butonu
      floatingActionButton: Consumer<StoryController>(
        builder: (context, storyController, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.reading);
            },
            backgroundColor: AppTheme.primaryColor,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Okumaya Başla',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Macera':
        return Icons.explore;
      case 'Hayvanlar':
        return Icons.pets;
      case 'Bilim':
        return Icons.science;
      case 'Dostluk':
        return Icons.favorite;
      case 'Doğa':
        return Icons.nature;
      case 'Aile':
        return Icons.family_restroom;
      case 'Okul':
        return Icons.school;
      case 'Fantastik':
        return Icons.auto_awesome;
      case 'Tarih':
        return Icons.history_edu;
      case 'Spor':
        return Icons.sports_soccer;
      default:
        return Icons.book;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
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
