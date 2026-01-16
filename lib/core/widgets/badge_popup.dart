import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../services/points_service.dart';
import '../constants/app_colors.dart';

/// Badge Popup - Rozet kazanma animasyonu
/// 
/// Özellikler:
/// - Konfeti animasyonu
/// - Rozet bilgisi
/// - Otomatik kapanma
class BadgePopup {
  static void show(
    BuildContext context, {
    required String badgeId,
    VoidCallback? onDismiss,
  }) {
    final pointsService = PointsService();
    final badgeInfo = pointsService.getBadgeInfo(badgeId);
    
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    confettiController.play();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BadgePopupDialog(
        badgeInfo: badgeInfo,
        confettiController: confettiController,
        onDismiss: () {
          confettiController.dispose();
          Navigator.pop(context);
          onDismiss?.call();
        },
      ),
    );
  }

  /// Birden fazla rozet göster
  static void showMultiple(
    BuildContext context, {
    required List<String> badgeIds,
    VoidCallback? onDismiss,
  }) {
    if (badgeIds.isEmpty) {
      onDismiss?.call();
      return;
    }

    final pointsService = PointsService();
    int currentIndex = 0;

    void showNext() {
      if (currentIndex >= badgeIds.length) {
        onDismiss?.call();
        return;
      }

      final badgeId = badgeIds[currentIndex];
      final badgeInfo = pointsService.getBadgeInfo(badgeId);
      
      final confettiController = ConfettiController(
        duration: const Duration(seconds: 3),
      );
      
      confettiController.play();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _BadgePopupDialog(
          badgeInfo: badgeInfo,
          confettiController: confettiController,
          currentBadge: currentIndex + 1,
          totalBadges: badgeIds.length,
          onDismiss: () {
            confettiController.dispose();
            Navigator.pop(context);
            currentIndex++;
            showNext();
          },
        ),
      );
    }

    showNext();
  }
}

class _BadgePopupDialog extends StatefulWidget {
  final Map<String, dynamic> badgeInfo;
  final ConfettiController confettiController;
  final VoidCallback onDismiss;
  final int? currentBadge;
  final int? totalBadges;

  const _BadgePopupDialog({
    Key? key,
    required this.badgeInfo,
    required this.confettiController,
    required this.onDismiss,
    this.currentBadge,
    this.totalBadges,
  }) : super(key: key);

  @override
  State<_BadgePopupDialog> createState() => _BadgePopupDialogState();
}

class _BadgePopupDialogState extends State<_BadgePopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: widget.confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            shouldLoop: false,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
              Colors.blue,
              Colors.pink,
              Colors.purple,
            ],
          ),
        ),

        // Dialog
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 0.1,
                  child: child,
                ),
              );
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(widget.badgeInfo['color']).withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge counter
                    if (widget.currentBadge != null && widget.totalBadges != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '${widget.currentBadge}/${widget.totalBadges}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Title
                    Text(
                      'YENİ ROZET!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Badge Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(widget.badgeInfo['color']).withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(widget.badgeInfo['color']).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.badgeInfo['icon'],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Badge Name
                    Text(
                      widget.badgeInfo['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Badge Description
                    Text(
                      widget.badgeInfo['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Close Button
                    ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(widget.badgeInfo['color']),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        widget.currentBadge != null && 
                        widget.currentBadge! < widget.totalBadges!
                            ? 'Sonraki'
                            : 'Harika!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
