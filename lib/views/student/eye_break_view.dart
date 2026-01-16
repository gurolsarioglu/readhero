import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Göz molası ekranı
/// 20-20-20 kuralı: 20 saniye uzağa bak
class EyeBreakView extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const EyeBreakView({
    super.key,
    this.durationSeconds = 20,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<EyeBreakView> createState() => _EyeBreakViewState();
}

class _EyeBreakViewState extends State<EyeBreakView>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _balloonController;
  
  // Balon pozisyonları
  final List<Offset> _balloonPositions = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _startTimer();
    _initBalloonAnimation();
    _generateBalloons();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _balloonController.dispose();
    super.dispose();
  }

  void _initBalloonAnimation() {
    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  void _generateBalloons() {
    // 5 balon oluştur
    for (int i = 0; i < 5; i++) {
      _balloonPositions.add(
        Offset(
          _random.nextDouble() * 0.8 + 0.1, // 0.1 - 0.9 arası
          _random.nextDouble() * 0.6 + 0.2, // 0.2 - 0.8 arası
        ),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: AppTheme.primaryColor.withOpacity(0.95),
      child: SafeArea(
        child: Stack(
          children: [
            // Balonlar (mini oyun)
            ...List.generate(_balloonPositions.length, (index) {
              return _buildBalloon(
                size,
                _balloonPositions[index],
                index,
              );
            }),

            // Ana içerik
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Göz ikonu
                    const Icon(
                      Icons.visibility_off,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 32),

                    // Başlık
                    const Text(
                      'Göz Molası Zamanı! 👁️',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Açıklama
                    const Text(
                      '20 saniye boyunca\n6 metre uzağa bakın',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Geri sayım
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_remainingSeconds',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // İpucu
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '💡 İpucu: Balonları takip edin!\nGözleriniz hareket etsin.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Atla butonu
                    TextButton(
                      onPressed: widget.onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Atla (Puan kazanamazsın)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // İlerleme çubuğu (üstte)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: 1 - (_remainingSeconds / widget.durationSeconds),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalloon(Size screenSize, Offset position, int index) {
    return AnimatedBuilder(
      animation: _balloonController,
      builder: (context, child) {
        // Yukarı aşağı hareket
        final offset = sin(_balloonController.value * 2 * pi + index) * 20;
        
        return Positioned(
          left: screenSize.width * position.dx,
          top: screenSize.height * position.dy + offset,
          child: Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: _getBalloonColor(index),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getBalloonEmoji(index),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBalloonColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];
    return colors[index % colors.length].withOpacity(0.3);
  }

  String _getBalloonEmoji(int index) {
    final emojis = ['🎈', '🎈', '🎈', '🎈', '🎈'];
    return emojis[index % emojis.length];
  }
}
