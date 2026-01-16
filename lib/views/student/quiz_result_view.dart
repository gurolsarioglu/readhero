import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../models/models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_theme.dart';

/// Quiz Result View - Sınav sonuç ekranı
/// 
/// Özellikler:
/// - Başarı durumu gösterimi
/// - Puan ve istatistikler
/// - Konfeti animasyonu (başarılı ise)
/// - Tekrar dene / Kütüphaneye dön butonları
class QuizResultView extends StatefulWidget {
  final QuizResultModel result;
  final String storyTitle;

  const QuizResultView({
    Key? key,
    required this.result,
    required this.storyTitle,
  }) : super(key: key);

  @override
  State<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends State<QuizResultView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Show confetti if passed
    if (widget.result.isPassed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: [AppColors.primary.withOpacity(0.05), Colors.white],
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _navigateToLibrary(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sınav Sonucu',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Result Icon
                    _buildResultIcon(),
                    
                    const SizedBox(height: 24),
                    
                    // Result Message
                    Text(
                      _getResultMessage(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Story Title
                    Text(
                      widget.storyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Score Card
                    _buildScoreCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // Statistics
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildStatistics(context),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
              
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.accent,
                    Colors.blue,
                    Colors.pink,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    String emoji;
    Color bgColor;
    
    if (widget.result.isPerfect) {
      emoji = '🏆';
      bgColor = AppColors.accent;
    } else if (widget.result.isPassed) {
      emoji = '🎉';
      bgColor = AppColors.secondary;
    } else {
      emoji = '💪';
      bgColor = Colors.orange;
    }
    
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  String _getResultMessage() {
    if (widget.result.isPerfect) {
      return 'Mükemmel!';
    } else if (widget.result.score >= 80) {
      return 'Harika!';
    } else if (widget.result.isPassed) {
      return 'Başarılı!';
    } else {
      return 'Tekrar Dene!';
    }
  }

  Color _getResultColor() {
    if (widget.result.isPerfect) {
      return AppColors.accent;
    } else if (widget.result.isPassed) {
      return AppColors.secondary;
    } else {
      return Colors.orange;
    }
  }

  Widget _buildScoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getResultColor(),
            _getResultColor().withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getResultColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Puanın',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.result.score}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.result.grade,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    // Calculate stats from answers
    int correctCount = 0;
    int wrongCount = 0;
    
    // Note: We would need to compare answers with correct answers
    // For now, we'll use the score to estimate
    final totalQuestions = widget.result.answers.length;
    correctCount = (widget.result.score / 100 * totalQuestions).round();
    wrongCount = totalQuestions - correctCount;
    
    return Column(
      children: [
        _buildStatCard(
          context,
          icon: Icons.check_circle,
          title: 'Doğru Cevaplar',
          value: '$correctCount',
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          icon: Icons.cancel,
          title: 'Yanlış Cevaplar',
          value: '$wrongCount',
          color: AppColors.error,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          icon: Icons.quiz,
          title: 'Toplam Soru',
          value: '$totalQuestions',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          icon: Icons.stars,
          title: 'Kazanılan Puan',
          value: '+${(widget.result.score * 0.6).round()}',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Try Again Button (if failed)
        if (!widget.result.isPassed)
          CustomButton(
            text: 'Tekrar Dene',
            onPressed: () => _retryQuiz(context),
            icon: Icons.refresh,
          ),
        
        if (!widget.result.isPassed)
          const SizedBox(height: 12),
        
        // Back to Library Button
        CustomButton(
          text: 'Kütüphaneye Dön',
          onPressed: () => _navigateToLibrary(context),
          icon: Icons.library_books,
          backgroundColor: widget.result.isPassed ? AppTheme.primaryColor : Colors.grey,
        ),
      ],
    );
  }

  void _retryQuiz(BuildContext context) {
    // Pop to reading view to retry
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _navigateToLibrary(BuildContext context) {
    // Pop to library
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
