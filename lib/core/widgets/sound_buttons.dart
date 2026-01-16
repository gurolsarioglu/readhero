import 'package:flutter/material.dart';
import '../services/sound_effects_service.dart';

/// Ses efektli buton widget'ı
/// Tıklandığında ses efekti çalan buton
class SoundButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool playSound;

  const SoundButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.playSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (playSound) {
                await SoundEffectsService().playButtonClick();
              }
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Ses efektli icon buton
class SoundIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final bool playSound;

  const SoundIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.playSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (playSound) {
                await SoundEffectsService().playButtonClick();
              }
              onPressed?.call();
            },
      icon: icon,
      tooltip: tooltip,
    );
  }
}

/// Ses efektli text buton
class SoundTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool playSound;

  const SoundTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.playSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (playSound) {
                await SoundEffectsService().playButtonClick();
              }
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Ses efektli outlined buton
class SoundOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool playSound;

  const SoundOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.playSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (playSound) {
                await SoundEffectsService().playButtonClick();
              }
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Ses efektli floating action button
class SoundFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final bool playSound;

  const SoundFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.playSound = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (playSound) {
                await SoundEffectsService().playButtonClick();
              }
              onPressed?.call();
            },
      tooltip: tooltip,
      child: child,
    );
  }
}
