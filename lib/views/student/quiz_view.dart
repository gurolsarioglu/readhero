import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/quiz_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import 'quiz_result_view.dart';

/// Quiz View - Ana sınav ekranı
/// 
/// Özellikler:
/// - Soru gösterimi
/// - Şık seçimi
/// - İlerleme takibi
/// - Geri sayım
class QuizView extends StatefulWidget {
  final String sessionId;
  final String storyTitle;

  const QuizView({
    Key? key,
    required this.sessionId,
    required this.storyTitle,
  }) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  @override
  void initState() {
    super.initState();
    // Start quiz timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizController>().startQuiz(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        body: GradientBackground(
          colors: [AppColors.primary.withOpacity(0.05), Colors.white],
          child: SafeArea(
            child: Consumer<QuizController>(
              builder: (context, controller, child) {
                if (controller.currentQuestion == null) {
                  return const Center(child: LoadingIndicator());
                }

                return Column(
                  children: [
                    // Header
                    _buildHeader(context, controller),
                    
                    // Progress Bar
                    _buildProgressBar(controller),
                    
                    // Question Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Number
                            Text(
                              'Soru ${controller.currentQuestionIndex + 1}/${controller.totalQuestions}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Question Text
                            Container(
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
                              child: Text(
                                controller.currentQuestion!.question,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Options
                            ...List.generate(
                              controller.currentQuestion!.options.length,
                              (index) => _buildOption(
                                context,
                                controller,
                                index,
                                controller.currentQuestion!.options[index],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Navigation
                    _buildBottomNavigation(context, controller),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QuizController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _onBackPressed(context),
          ),
          Expanded(
            child: Text(
              widget.storyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: controller.timeRemaining < 60
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: controller.timeRemaining < 60
                      ? AppColors.error
                      : AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  controller.formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: controller.timeRemaining < 60
                        ? AppColors.error
                        : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuizController controller) {
    return LinearProgressIndicator(
      value: controller.progressPercentage,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 4,
    );
  }

  Widget _buildOption(
    BuildContext context,
    QuizController controller,
    int index,
    String option,
  ) {
    final isSelected = controller.currentAnswer == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.selectAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Option Letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option Text
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppColors.primary : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              // Check Icon
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, QuizController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (controller.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Önceki'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          
          if (controller.currentQuestionIndex > 0)
            const SizedBox(width: 12),
          
          // Next/Finish Button
          Expanded(
            flex: controller.currentQuestionIndex > 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: controller.currentAnswer != null
                  ? () => _handleNext(context, controller)
                  : null,
              icon: Icon(
                controller.isLastQuestion ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(
                controller.isLastQuestion ? 'Bitir' : 'Sonraki',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(BuildContext context, QuizController controller) {
    if (controller.isLastQuestion) {
      _finishQuiz(context, controller);
    } else {
      controller.nextQuestion();
    }
  }

  Future<void> _finishQuiz(BuildContext context, QuizController controller) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: LoadingIndicator(),
      ),
    );
    
    // Finish quiz and get result
    final result = await controller.finishQuiz(widget.sessionId);
    
    // Hide loading
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    if (result == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sınav sonucu kaydedilemedi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    // Navigate to result
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultView(
            result: result,
            storyTitle: widget.storyTitle,
          ),
        ),
      );
    }
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavdan Çık'),
        content: const Text(
          'Sınavdan çıkmak istediğine emin misin? İlerleme kaydedilmeyecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
    
    return shouldExit ?? false;
  }
}
