import 'dart:async';
import 'package:flutter/foundation.dart';

/// Göz molası servisi
/// 20-20-20 kuralı: Her 20 dakikada 20 saniye mola
class EyeBreakService extends ChangeNotifier {
  Timer? _timer;
  bool _isEnabled = true;
  int _breakIntervalMinutes = 20; // Varsayılan 20 dakika
  int _breakDurationSeconds = 20; // Varsayılan 20 saniye
  
  DateTime? _lastBreakTime;
  int _totalBreaksTaken = 0;
  
  // Callback fonksiyonu
  Function()? _onBreakTimeCallback;

  // ==================== GETTERS ====================

  /// Mola sistemi aktif mi?
  bool get isEnabled => _isEnabled;

  /// Mola aralığı (dakika)
  int get breakIntervalMinutes => _breakIntervalMinutes;

  /// Mola süresi (saniye)
  int get breakDurationSeconds => _breakDurationSeconds;

  /// Son mola zamanı
  DateTime? get lastBreakTime => _lastBreakTime;

  /// Toplam alınan mola sayısı
  int get totalBreaksTaken => _totalBreaksTaken;

  /// Bir sonraki molaya kalan süre (saniye)
  int get secondsUntilNextBreak {
    if (_lastBreakTime == null) {
      return _breakIntervalMinutes * 60;
    }
    
    final elapsed = DateTime.now().difference(_lastBreakTime!).inSeconds;
    final remaining = (_breakIntervalMinutes * 60) - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// Bir sonraki molaya kalan süre (formatlanmış)
  String get formattedTimeUntilNextBreak {
    final seconds = secondsUntilNextBreak;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ==================== SERVİS YÖNETİMİ ====================

  /// Servisi başlat
  void start({Function()? onBreakTime}) {
    _onBreakTimeCallback = onBreakTime;
    _isEnabled = true;
    _startTimer();
    notifyListeners();
  }

  /// Servisi durdur
  void stop() {
    _isEnabled = false;
    _stopTimer();
    notifyListeners();
  }

  /// Servisi aktif/pasif yap
  void toggle() {
    if (_isEnabled) {
      stop();
    } else {
      start(onBreakTime: _onBreakTimeCallback);
    }
  }

  /// Mola aralığını ayarla (dakika)
  void setBreakInterval(int minutes) {
    if (minutes < 5 || minutes > 60) {
      throw Exception('Mola aralığı 5-60 dakika arasında olmalıdır');
    }
    
    _breakIntervalMinutes = minutes;
    
    // Timer'ı yeniden başlat
    if (_isEnabled) {
      _stopTimer();
      _startTimer();
    }
    
    notifyListeners();
  }

  /// Mola süresini ayarla (saniye)
  void setBreakDuration(int seconds) {
    if (seconds < 10 || seconds > 60) {
      throw Exception('Mola süresi 10-60 saniye arasında olmalıdır');
    }
    
    _breakDurationSeconds = seconds;
    notifyListeners();
  }

  // ==================== MOLA YÖNETİMİ ====================

  /// Molayı tamamla
  void completeBreak() {
    _lastBreakTime = DateTime.now();
    _totalBreaksTaken++;
    notifyListeners();
  }

  /// Molayı atla
  void skipBreak() {
    _lastBreakTime = DateTime.now();
    notifyListeners();
  }

  /// İstatistikleri sıfırla
  void resetStats() {
    _totalBreaksTaken = 0;
    _lastBreakTime = null;
    notifyListeners();
  }

  // ==================== TIMER YÖNETİMİ ====================

  /// Timer'ı başlat
  void _startTimer() {
    _stopTimer();
    
    // İlk mola zamanını ayarla
    if (_lastBreakTime == null) {
      _lastBreakTime = DateTime.now();
    }
    
    // Her dakika kontrol et
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkBreakTime();
    });
  }

  /// Timer'ı durdur
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Mola zamanı geldi mi kontrol et
  void _checkBreakTime() {
    if (!_isEnabled || _lastBreakTime == null) return;
    
    final elapsed = DateTime.now().difference(_lastBreakTime!).inMinutes;
    
    if (elapsed >= _breakIntervalMinutes) {
      // Mola zamanı!
      _triggerBreak();
    }
  }

  /// Molayı tetikle
  void _triggerBreak() {
    if (_onBreakTimeCallback != null) {
      _onBreakTimeCallback!();
    }
  }

  // ==================== DISPOSE ====================

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
