import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ses efektleri servisi
/// Uygulama genelinde ses efektlerini yönetir
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  static const String _soundEnabledKey = 'sound_effects_enabled';
  bool _soundEnabled = true;

  /// Ses efektleri açık mı?
  bool get isSoundEnabled => _soundEnabled;

  /// Ses efektlerini başlat
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Ses efektlerini aç/kapat
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  /// Buton tıklama sesi
  Future<void> playButtonClick() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Başarı sesi (ding!)
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      // Sistem başarı sesi
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Hata sesi
  Future<void> playError() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Rozet kazanma sesi
  Future<void> playBadgeEarned() async {
    if (!_soundEnabled) return;
    try {
      // Özel rozet sesi için titreşim kombinasyonu
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Puan kazanma sesi
  Future<void> playPointsEarned() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Seviye atlama sesi
  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Hedef tamamlama sesi
  Future<void> playGoalCompleted() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Okuma başlama sesi
  Future<void> playReadingStart() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Okuma bitirme sesi
  Future<void> playReadingComplete() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Sınav başlama sesi
  Future<void> playQuizStart() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Sınav bitirme sesi
  Future<void> playQuizComplete() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Doğru cevap sesi
  Future<void> playCorrectAnswer() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }

  /// Yanlış cevap sesi
  Future<void> playWrongAnswer() async {
    if (!_soundEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ses çalınamazsa sessizce devam et
    }
  }
}
