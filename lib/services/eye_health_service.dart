import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Göz sağlığı ayarları servisi
class EyeHealthService {
  static final EyeHealthService instance = EyeHealthService._init();
  EyeHealthService._init();

  // Ayar anahtarları
  static const String _keyBlinkReminderEnabled = 'blink_reminder_enabled';
  static const String _keyBlinkReminderInterval = 'blink_reminder_interval';
  static const String _keyBlueLightFilterEnabled = 'blue_light_filter_enabled';
  static const String _keyBlueLightFilterIntensity = 'blue_light_filter_intensity';
  static const String _keyAdaptiveTextEnabled = 'adaptive_text_enabled';
  static const String _keyBaseFontSize = 'base_font_size';
  static const String _keyLineHeight = 'line_height';

  // Varsayılan değerler
  static const int defaultBlinkInterval = 20; // 20 saniye
  static const double defaultBlueLightIntensity = 0.3; // %30
  static const double defaultFontSize = 18.0;
  static const double defaultLineHeight = 1.5;

  SharedPreferences? _prefs;

  /// Servisi başlat
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== GÖZ KIRPMA HATIRLATICI ====================

  /// Göz kırpma hatırlatıcısı aktif mi?
  bool get isBlinkReminderEnabled {
    return _prefs?.getBool(_keyBlinkReminderEnabled) ?? false;
  }

  /// Göz kırpma hatırlatıcısını aç/kapat
  Future<void> setBlinkReminderEnabled(bool enabled) async {
    await _prefs?.setBool(_keyBlinkReminderEnabled, enabled);
  }

  /// Göz kırpma hatırlatma aralığı (saniye)
  int get blinkReminderInterval {
    return _prefs?.getInt(_keyBlinkReminderInterval) ?? defaultBlinkInterval;
  }

  /// Göz kırpma hatırlatma aralığını ayarla
  Future<void> setBlinkReminderInterval(int seconds) async {
    await _prefs?.setInt(_keyBlinkReminderInterval, seconds);
  }

  // ==================== MAVİ IŞIK FİLTRESİ ====================

  /// Mavi ışık filtresi aktif mi?
  bool get isBlueLightFilterEnabled {
    return _prefs?.getBool(_keyBlueLightFilterEnabled) ?? false;
  }

  /// Mavi ışık filtresini aç/kapat
  Future<void> setBlueLightFilterEnabled(bool enabled) async {
    await _prefs?.setBool(_keyBlueLightFilterEnabled, enabled);
  }

  /// Mavi ışık filtresi yoğunluğu (0.0 - 1.0)
  double get blueLightFilterIntensity {
    return _prefs?.getDouble(_keyBlueLightFilterIntensity) ?? defaultBlueLightIntensity;
  }

  /// Mavi ışık filtresi yoğunluğunu ayarla
  Future<void> setBlueLightFilterIntensity(double intensity) async {
    await _prefs?.setDouble(_keyBlueLightFilterIntensity, intensity.clamp(0.0, 1.0));
  }

  /// Mavi ışık filtresi rengi
  Color get blueLightFilterColor {
    final intensity = blueLightFilterIntensity;
    return Color.fromRGBO(255, 200, 100, intensity);
  }

  // ==================== ADAPTİF METİN ====================

  /// Adaptif metin aktif mi?
  bool get isAdaptiveTextEnabled {
    return _prefs?.getBool(_keyAdaptiveTextEnabled) ?? true;
  }

  /// Adaptif metni aç/kapat
  Future<void> setAdaptiveTextEnabled(bool enabled) async {
    await _prefs?.setBool(_keyAdaptiveTextEnabled, enabled);
  }

  /// Temel font boyutu
  double get baseFontSize {
    return _prefs?.getDouble(_keyBaseFontSize) ?? defaultFontSize;
  }

  /// Temel font boyutunu ayarla
  Future<void> setBaseFontSize(double size) async {
    await _prefs?.setDouble(_keyBaseFontSize, size.clamp(14.0, 28.0));
  }

  /// Satır yüksekliği
  double get lineHeight {
    return _prefs?.getDouble(_keyLineHeight) ?? defaultLineHeight;
  }

  /// Satır yüksekliğini ayarla
  Future<void> setLineHeight(double height) async {
    await _prefs?.setDouble(_keyLineHeight, height.clamp(1.2, 2.0));
  }

  /// Okuma süresine göre adaptif font boyutu hesapla
  double getAdaptiveFontSize(Duration readingDuration) {
    if (!isAdaptiveTextEnabled) return baseFontSize;

    // Her 10 dakikada 0.5 puan artır (max 4 puan)
    final minutes = readingDuration.inMinutes;
    final increment = (minutes / 10) * 0.5;
    final adaptiveSize = baseFontSize + increment.clamp(0.0, 4.0);

    return adaptiveSize.clamp(14.0, 28.0);
  }

  /// Okuma süresine göre adaptif satır yüksekliği hesapla
  double getAdaptiveLineHeight(Duration readingDuration) {
    if (!isAdaptiveTextEnabled) return lineHeight;

    // Her 15 dakikada 0.05 artır (max 0.3)
    final minutes = readingDuration.inMinutes;
    final increment = (minutes / 15) * 0.05;
    final adaptiveHeight = lineHeight + increment.clamp(0.0, 0.3);

    return adaptiveHeight.clamp(1.2, 2.0);
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Tüm ayarları sıfırla
  Future<void> resetAllSettings() async {
    await _prefs?.setBool(_keyBlinkReminderEnabled, false);
    await _prefs?.setInt(_keyBlinkReminderInterval, defaultBlinkInterval);
    await _prefs?.setBool(_keyBlueLightFilterEnabled, false);
    await _prefs?.setDouble(_keyBlueLightFilterIntensity, defaultBlueLightIntensity);
    await _prefs?.setBool(_keyAdaptiveTextEnabled, true);
    await _prefs?.setDouble(_keyBaseFontSize, defaultFontSize);
    await _prefs?.setDouble(_keyLineHeight, defaultLineHeight);
  }

  /// Ayarları JSON olarak al
  Map<String, dynamic> getSettingsAsJson() {
    return {
      'blinkReminderEnabled': isBlinkReminderEnabled,
      'blinkReminderInterval': blinkReminderInterval,
      'blueLightFilterEnabled': isBlueLightFilterEnabled,
      'blueLightFilterIntensity': blueLightFilterIntensity,
      'adaptiveTextEnabled': isAdaptiveTextEnabled,
      'baseFontSize': baseFontSize,
      'lineHeight': lineHeight,
    };
  }
}
