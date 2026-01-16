import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/quiz_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import 'quiz_view.dart';

/// Quiz Intro View - Sınav giriş ekranı
/// 
/// Özellikler:
/// - Sınav kuralları açıklaması
/// - Animasyonlu karakter
/// - Başla butonu
class QuizIntroView extends StatelessWidget {
  final String storyId;
  final String storyTitle;
  final String sessionId;

  const QuizIntroView({
    Key? key,
    this.storyId = '',
    this.storyTitle = '',
    this.sessionId = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: [AppColors.primary.withOpacity(0.05), Colors.white],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Anlama Sınavı',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Mascot Character
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🎓',
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Story Title
                Text(
                  storyTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Quiz Info Cards
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoCard(
                          context,
                          icon: Icons.quiz,
                          title: '5 Soru',
                          description: 'Hikaye hakkında 5 soru cevaplayacaksın',
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.timer,
                          title: '10 Dakika',
                          description: 'Sınavı tamamlamak için 10 dakikan var',
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.stars,
                          title: 'Puan Kazan',
                          description: 'Doğru cevaplarla puan kazanacaksın',
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.lightbulb,
                          title: 'İpucu',
                          description: 'Her soruyu dikkatlice oku ve düşün',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Start Button
                CustomButton(
                  text: 'Sınava Başla',
                  onPressed: () => _startQuiz(context),
                  icon: Icons.play_arrow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz(BuildContext context) async {
    final quizController = context.read<QuizController>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: LoadingIndicator(),
      ),
    );
    
    // Load quiz
    await quizController.loadQuiz(storyId);
    
    // Hide loading
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    // Check for errors
    if (quizController.errorMessage != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quizController.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    // Navigate to quiz
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizView(
            sessionId: sessionId,
            storyTitle: storyTitle,
          ),
        ),
      );
    }
  }
}
