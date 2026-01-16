import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Özel loading indicator'lar
class CustomLoadingIndicators {
  /// Dönen kitap animasyonu
  static Widget bookSpinner({Color? color}) {
    return _BookSpinner(color: color ?? AppTheme.primaryColor);
  }

  /// Nokta nokta loading
  static Widget dots({Color? color}) {
    return _DotsLoading(color: color ?? AppTheme.primaryColor);
  }

  /// Pulse loading
  static Widget pulse({Color? color}) {
    return _PulseLoading(color: color ?? AppTheme.primaryColor);
  }

  /// Wave loading
  static Widget wave({Color? color}) {
    return _WaveLoading(color: color ?? AppTheme.primaryColor);
  }
}

/// Dönen kitap loading
class _BookSpinner extends StatefulWidget {
  final Color color;

  const _BookSpinner({required this.color});

  @override
  State<_BookSpinner> createState() => _BookSpinnerState();
}

class _BookSpinnerState extends State<_BookSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Icon(
            Icons.menu_book,
            size: 48,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Nokta nokta loading
class _DotsLoading extends StatefulWidget {
  final Color color;

  const _DotsLoading({required this.color});

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final scale = value < 0.5 ? value * 2 : (1 - value) * 2;

            return Transform.scale(
              scale: 0.5 + (scale * 0.5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Pulse loading
class _PulseLoading extends StatefulWidget {
  final Color color;

  const _PulseLoading({required this.color});

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3 + (_controller.value * 0.7)),
          ),
          child: Center(
            child: Icon(
              Icons.book,
              size: 30,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// Wave loading
class _WaveLoading extends StatefulWidget {
  final Color color;

  const _WaveLoading({required this.color});

  @override
  State<_WaveLoading> createState() => _WaveLoadingState();
}

class _WaveLoadingState extends State<_WaveLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.1;
            final value = (_controller.value - delay) % 1.0;
            final height = 10 + (value < 0.5 ? value * 40 : (1 - value) * 40);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Success animasyonu (check mark)
class SuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Color? color;

  const SuccessAnimation({
    Key? key,
    this.onComplete,
    this.color,
  }) : super(key: key);

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color ?? AppTheme.successColor,
            ),
            child: CustomPaint(
              painter: _CheckMarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Check mark painter
class _CheckMarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckMarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Check mark path
    final startPoint = Offset(center.dx - 15, center.dy);
    final middlePoint = Offset(center.dx - 5, center.dy + 10);
    final endPoint = Offset(center.dx + 15, center.dy - 10);

    if (progress < 0.5) {
      // First half: draw from start to middle
      final t = progress * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(
        startPoint.dx + (middlePoint.dx - startPoint.dx) * t,
        startPoint.dy + (middlePoint.dy - startPoint.dy) * t,
      );
    } else {
      // Second half: draw from middle to end
      final t = (progress - 0.5) * 2;
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(middlePoint.dx, middlePoint.dy);
      path.lineTo(
        middlePoint.dx + (endPoint.dx - middlePoint.dx) * t,
        middlePoint.dy + (endPoint.dy - middlePoint.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Loading overlay
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {String? message}) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomLoadingIndicators.bookSpinner(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
