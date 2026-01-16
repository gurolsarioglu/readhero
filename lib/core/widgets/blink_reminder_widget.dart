import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/eye_health_service.dart';
import '../theme/app_theme.dart';
import 'mascot_widget.dart';

/// Göz kırpma hatırlatıcısı widget'ı
class BlinkReminderWidget extends StatefulWidget {
  final Widget child;

  const BlinkReminderWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<BlinkReminderWidget> createState() => _BlinkReminderWidgetState();
}

class _BlinkReminderWidgetState extends State<BlinkReminderWidget> {
  Timer? _reminderTimer;
  final _eyeHealthService = EyeHealthService.instance;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _startReminderTimer();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();

    if (!_eyeHealthService.isBlinkReminderEnabled) return;

    final interval = _eyeHealthService.blinkReminderInterval;
    _reminderTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) => _showBlinkReminder(),
    );
  }

  void _showBlinkReminder() {
    if (!mounted) return;
    if (_overlayEntry != null) return; // Zaten gösteriliyorsa

    _overlayEntry = OverlayEntry(
      builder: (context) => _BlinkReminderOverlay(
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // 5 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 5), () {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Göz kırpma hatırlatıcısı overlay
class _BlinkReminderOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _BlinkReminderOverlay({required this.onDismiss});

  @override
  State<_BlinkReminderOverlay> createState() => _BlinkReminderOverlayState();
}

class _BlinkReminderOverlayState extends State<_BlinkReminderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MascotWidget(
                    mood: MascotMood.sleepy,
                    message: '',
                    showSpeechBubble: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Göz Molası Zamanı! 👀',
                    style: AppTheme.headlineStyle.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '20-20-20 Kuralı:\n'
                    '20 dakikada bir, 20 saniye boyunca,\n'
                    '20 adım uzaktaki bir noktaya bak!',
                    style: AppTheme.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        'Göz Egzersizi',
                        Icons.visibility_outlined,
                        AppTheme.primaryColor,
                        () {
                          widget.onDismiss();
                          _showEyeExercise(context);
                        },
                      ),
                      _buildActionButton(
                        'Tamam',
                        Icons.check,
                        AppTheme.successColor,
                        widget.onDismiss,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showEyeExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _EyeExerciseDialog(),
    );
  }
}

/// Basit göz egzersizi dialog'u
class _EyeExerciseDialog extends StatefulWidget {
  const _EyeExerciseDialog();

  @override
  State<_EyeExerciseDialog> createState() => _EyeExerciseDialogState();
}

class _EyeExerciseDialogState extends State<_EyeExerciseDialog> {
  int _countdown = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '👀',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'Uzağa Bak',
              style: AppTheme.headlineStyle,
            ),
            const SizedBox(height: 12),
            Text(
              '20 adım uzaktaki bir noktaya\n$_countdown saniye boyunca bak',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _countdown / 20,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$_countdown',
                      style: AppTheme.headlineStyle.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Atla'),
            ),
          ],
        ),
      ),
    );
  }
}
