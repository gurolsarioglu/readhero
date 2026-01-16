import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../services/eye_break_service.dart';
import 'eye_break_view.dart';

/// Okuma ekranı
class ReadingView extends StatefulWidget {
  const ReadingView({super.key});

  @override
  State<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends State<ReadingView> {
  final ScrollController _scrollController = ScrollController();
  bool _showBionicText = false;
  final EyeBreakService _eyeBreakService = EyeBreakService();

  @override
  void initState() {
    super.initState();
    _initializeReading();
    _scrollController.addListener(_onScroll);
    _startEyeBreakService();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _eyeBreakService.stop();
    super.dispose();
  }

  void _startEyeBreakService() {
    _eyeBreakService.start(
      onBreakTime: () {
        if (mounted) {
          _showEyeBreakDialog();
        }
      },
    );
  }

  void _showEyeBreakDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EyeBreakView(
        onComplete: () {
          Navigator.pop(context);
          _eyeBreakService.completeBreak();
          // +5 puan ekle
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Göz molası tamamlandı! +5 puan kazandın!'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
        },
        onSkip: () {
          Navigator.pop(context);
          _eyeBreakService.skipBreak();
        },
      ),
    );
  }

  void _initializeReading() {
    final readingController = context.read<ReadingController>();
    final storyController = context.read<StoryController>();
    final studentController = context.read<StudentController>();

    final story = storyController.selectedStory;
    final student = studentController.selectedStudent;

    if (story != null && student != null) {
      readingController.startReading(story: story, student: student);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final progress = maxScroll > 0 ? currentScroll / maxScroll : 0.0;

    context.read<ReadingController>().updateProgress(progress);
  }

  void _onPauseResume() {
    final controller = context.read<ReadingController>();
    if (controller.isPaused) {
      controller.resumeReading();
    } else {
      controller.pauseReading();
    }
  }

  Future<void> _onFinish() async {
    final controller = context.read<ReadingController>();
    
    // Onay dialogu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Okumayı Bitir'),
        content: const Text(
          'Okumayı bitirmek istediğinize emin misiniz? '
          'İlerlemeniz kaydedilecek ve sınava geçeceksiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Bitir ve Sınava Geç'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await controller.finishReading();
      
      if (success && mounted) {
        final session = controller.currentSession;
        final story = controller.currentStory;
        
        if (session != null && story != null) {
          // Navigate to quiz
          Navigator.pushReplacementNamed(
            context,
            '/quiz-intro',
            arguments: {
              'storyId': story.id,
              'storyTitle': story.title,
              'sessionId': session.id,
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = context.read<ReadingController>();
        if (controller.isReading) {
          // Çıkış onayı
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Çıkmak İstediğinize Emin Misiniz?'),
              content: const Text(
                'Okuma devam ediyor. Çıkarsanız ilerlemeniz kaydedilmeyecek.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Devam Et'),
                ),
                TextButton(
                  onPressed: () {
                    controller.cancelReading();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    'Çık',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
          );
          return confirmed ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ReadingController>(
            builder: (context, controller, child) {
              return Text(controller.currentStory?.title ?? 'Okuma');
            },
          ),
          backgroundColor: AppTheme.primaryColor,
          actions: [
            // Biyonik okuma toggle
            IconButton(
              icon: Icon(_showBionicText ? Icons.format_bold : Icons.format_clear),
              onPressed: () {
                setState(() {
                  _showBionicText = !_showBionicText;
                });
              },
              tooltip: 'Biyonik Okuma',
            ),
          ],
        ),
        body: Consumer<ReadingController>(
          builder: (context, controller, child) {
            if (controller.currentStory == null) {
              return const Center(
                child: Text('Hikaye bulunamadı'),
              );
            }

            final story = controller.currentStory!;
            final student = controller.currentStudent!;
            final showTimer = student.gradeLevel > 1; // 2-4. sınıf için timer göster

            return Column(
              children: [
                // İlerleme çubuğu
                LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),

                // Timer ve WPM (2-4. sınıf için)
                if (showTimer)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Süre
                        _buildTimerInfo(
                          'Süre',
                          controller.formattedTime,
                          Icons.access_time,
                        ),
                        // WPM
                        _buildTimerInfo(
                          'WPM',
                          controller.wordsPerMinute.toString(),
                          Icons.speed,
                        ),
                        // Kalan süre (tahmini)
                        if (controller.wordsPerMinute > 0)
                          _buildTimerInfo(
                            'Kalan',
                            controller.formattedRemainingTime,
                            Icons.hourglass_empty,
                          ),
                      ],
                    ),
                  ),

                // Hikaye metni
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: _showBionicText
                        ? _buildBionicText(story.content)
                        : Text(
                            story.content,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.8,
                              letterSpacing: 0.3,
                              fontFamily: 'Nunito',
                            ),
                          ),
                  ),
                ),

                // Kontrol butonları
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Pause/Resume
                      Expanded(
                        child: CustomButton(
                          text: controller.isPaused ? 'Devam Et' : 'Duraklat',
                          onPressed: _onPauseResume,
                          backgroundColor: controller.isPaused
                              ? AppTheme.secondaryColor
                              : AppTheme.accentColor,
                          icon: controller.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Finish
                      Expanded(
                        child: CustomButton(
                          text: 'Bitir',
                          onPressed: _onFinish,
                          backgroundColor: AppTheme.primaryColor,
                          icon: Icons.check,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
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

  Widget _buildBionicText(String text) {
    // Biyonik okuma: Kelimelerin ilk %40'ı bold
    final words = text.split(' ');
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          height: 1.8,
          letterSpacing: 0.3,
          color: AppTheme.textPrimaryColor,
          fontFamily: 'Nunito',
        ),
        children: words.map((word) {
          if (word.isEmpty) return const TextSpan(text: ' ');
          
          final boldLength = (word.length * 0.4).ceil();
          final boldPart = word.substring(0, boldLength);
          final normalPart = word.substring(boldLength);
          
          return TextSpan(
            children: [
              TextSpan(
                text: boldPart,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: normalPart),
              const TextSpan(text: ' '),
            ],
          );
        }).toList(),
      ),
    );
  }
}
