import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// AI Test ekranı - Hikaye üretimi demo
class AITestView extends StatefulWidget {
  const AITestView({super.key});

  @override
  State<AITestView> createState() => _AITestViewState();
}

class _AITestViewState extends State<AITestView> {
  int _selectedGradeLevel = 1;
  String _selectedCategory = 'Macera';

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    final aiController = context.read<AIController>();
    if (!aiController.isInitialized) {
      await aiController.initialize();
    }
  }

  Future<void> _generateStory() async {
    final aiController = context.read<AIController>();
    
    final story = await aiController.generateStory(
      gradeLevel: _selectedGradeLevel,
      category: _selectedCategory,
    );

    if (!mounted) return;

    if (story != null) {
      _showSuccess('Hikaye başarıyla oluşturuldu!');
    } else {
      _showError(aiController.errorMessage ?? 'Hikaye oluşturulamadı');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hikaye Üretici'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AIController>(
          builder: (context, aiController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    'Gemini AI Test',
                    style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI ile hikaye üretin ve test edin',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // AI Durumu
                  CustomCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            aiController.isInitialized
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: aiController.isInitialized
                                ? AppTheme.secondaryColor
                                : AppTheme.errorColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            aiController.isInitialized
                                ? 'AI Hazır'
                                : 'AI Başlatılıyor...',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sınıf Seviyesi
                  Text(
                    'Sınıf Seviyesi',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(4, (index) {
                      final grade = index + 1;
                      final isSelected = _selectedGradeLevel == grade;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGradeLevel = grade;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.dividerColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '$grade. Sınıf',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Kategori
                  Text(
                    'Kategori',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: aiController.categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.dividerColor,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Üret Butonu
                  CustomButton(
                    text: 'Hikaye Üret',
                    onPressed: aiController.isInitialized ? () => _generateStory() : null,
                    width: double.infinity,
                    isLoading: aiController.isLoading,
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 24),

                  // Üretilen Hikaye
                  if (aiController.generatedStory != null) ...[
                    Text(
                      'Üretilen Hikaye',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık
                            Text(
                              aiController.generatedStory!.title,
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Meta bilgiler
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildMetaChip(
                                  '${aiController.generatedStory!.gradeLevel}. Sınıf',
                                  Icons.school,
                                ),
                                _buildMetaChip(
                                  aiController.generatedStory!.category,
                                  Icons.category,
                                ),
                                _buildMetaChip(
                                  '${aiController.generatedStory!.wordCount} kelime',
                                  Icons.text_fields,
                                ),
                                _buildMetaChip(
                                  aiController.generatedStory!.difficulty,
                                  Icons.signal_cellular_alt,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            // İçerik
                            Text(
                              aiController.generatedStory!.content,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Anahtar kelimeler
                            if (aiController.generatedStory!.keywords.isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                'Anahtar Kelimeler:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: aiController.generatedStory!.keywords
                                    .map((keyword) => Chip(
                                          label: Text(keyword),
                                          backgroundColor:
                                              AppTheme.accentColor.withOpacity(0.2),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Hata mesajı
                  if (aiController.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppTheme.errorColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              aiController.errorMessage!,
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
