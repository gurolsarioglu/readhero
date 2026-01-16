import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mascot durumları
enum MascotMood {
  happy,      // 😊 Mutlu
  thinking,   // 🤔 Düşünen
  celebrate,  // 🎉 Kutlama
  sad,        // 😢 Üzgün
  warning,    // ⚠️ Uyarı
  excited,    // 🤩 Heyecanlı
  sleepy,     // 😴 Uykulu
  cool,       // 😎 Havalı
}

/// Basit mascot widget (emoji tabanlı)
class MascotWidget extends StatefulWidget {
  final MascotMood mood;
  final String message;
  final bool showSpeechBubble;
  final VoidCallback? onTap;

  const MascotWidget({
    Key? key,
    required this.mood,
    required this.message,
    this.showSpeechBubble = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmoji() {
    switch (widget.mood) {
      case MascotMood.happy:
        return '😊';
      case MascotMood.thinking:
        return '🤔';
      case MascotMood.celebrate:
        return '🎉';
      case MascotMood.sad:
        return '😢';
      case MascotMood.warning:
        return '⚠️';
      case MascotMood.excited:
        return '🤩';
      case MascotMood.sleepy:
        return '😴';
      case MascotMood.cool:
        return '😎';
    }
  }

  Color _getBubbleColor() {
    switch (widget.mood) {
      case MascotMood.happy:
      case MascotMood.excited:
      case MascotMood.cool:
        return AppTheme.primaryColor;
      case MascotMood.celebrate:
        return AppTheme.accentColor;
      case MascotMood.thinking:
        return AppTheme.secondaryColor;
      case MascotMood.sad:
        return AppTheme.errorColor;
      case MascotMood.warning:
        return Colors.orange;
      case MascotMood.sleepy:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSpeechBubble) _buildSpeechBubble(),
          if (widget.showSpeechBubble) const SizedBox(height: 8),
          _buildMascot(),
        ],
      ),
    );
  }

  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getBubbleColor().withOpacity(0.1),
                border: Border.all(
                  color: _getBubbleColor().withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _getEmoji(),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getBubbleColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ReadHero',
                style: AppTheme.captionStyle.copyWith(
                  color: _getBubbleColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            style: AppTheme.bodyStyle,
          ),
        ],
      ),
    );
  }
}

/// Mascot ile dialog gösterme
class MascotDialog {
  static Future<void> show(
    BuildContext context, {
    required MascotMood mood,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MascotWidget(
                mood: mood,
                message: '',
                showSpeechBubble: false,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTheme.headlineStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onPressed != null) onPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText ?? 'Tamam',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Başarı mesajı
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      mood: MascotMood.celebrate,
      title: title,
      message: message,
      buttonText: 'Harika!',
      onPressed: onPressed,
    );
  }

  /// Hata mesajı
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      mood: MascotMood.sad,
      title: title,
      message: message,
      buttonText: 'Anladım',
      onPressed: onPressed,
    );
  }

  /// Bilgi mesajı
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      mood: MascotMood.thinking,
      title: title,
      message: message,
      buttonText: 'Tamam',
      onPressed: onPressed,
    );
  }

  /// Uyarı mesajı
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      mood: MascotMood.warning,
      title: title,
      message: message,
      buttonText: 'Anladım',
      onPressed: onPressed,
    );
  }
}
