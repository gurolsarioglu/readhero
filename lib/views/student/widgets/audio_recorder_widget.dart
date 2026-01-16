import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database_helper.dart';
import '../../../models/audio_recording.dart';
import '../../../models/story_model.dart';

/// Ses kaydı widget'ı (1. sınıf öğrencileri için)
/// Okuma sırasında ses kaydı yapma özelliği
class AudioRecorderWidget extends StatefulWidget {
  final String studentId;
  final String storyId;
  final VoidCallback? onRecordingComplete;

  const AudioRecorderWidget({
    super.key,
    required this.studentId,
    required this.storyId,
    this.onRecordingComplete,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final _audioRecorder = AudioRecorder();
  
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasPermission = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;
  
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    
    // Dalga animasyonu için controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _waveAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Mikrofon iznini kontrol et
  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  /// Mikrofon izni iste
  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
    
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses kaydı için mikrofon izni gereklidir'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Kaydı başlat
  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _requestPermission();
      if (!_hasPermission) return;
    }

    try {
      // Kayıt dizinini oluştur
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${recordingsDir.path}/recording_${widget.studentId}_${widget.storyId}_$timestamp.m4a';

      // Kaydı başlat
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordDuration = 0;
      });

      // Timer başlat
      _startTimer();
    } catch (e) {
      debugPrint('Kayıt başlatma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başlatılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Kaydı duraklat
  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      setState(() => _isPaused = true);
      _timer?.cancel();
    } catch (e) {
      debugPrint('Kayıt duraklatma hatası: $e');
    }
  }

  /// Kaydı devam ettir
  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      setState(() => _isPaused = false);
      _startTimer();
    } catch (e) {
      debugPrint('Kayıt devam ettirme hatası: $e');
    }
  }

  /// Kaydı durdur
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });

      if (path != null) {
        // Kayıt tamamlandı, veritabanına kaydet
        await _saveRecordingToDatabase(path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ses kaydı başarıyla tamamlandı!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        widget.onRecordingComplete?.call();
      }
    } catch (e) {
      debugPrint('Kayıt durdurma hatası: $e');
    }
  }

  /// Kaydı iptal et
  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();
      
      // Dosyayı sil
      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordDuration = 0;
        _audioPath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses kaydı iptal edildi'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Kayıt iptal hatası: $e');
    }
  }

  /// Timer başlat
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordDuration++);
    });
  }

  /// Kaydı veritabanına kaydet
  Future<void> _saveRecordingToDatabase(String filePath) async {
    try {
      final db = DatabaseHelper.instance;
      
      // Hikaye başlığını al (isteğe bağlı)
      String? storyTitle;
      final storyData = await db.getById('stories', widget.storyId);
      if (storyData != null) {
        storyTitle = storyData['title'] as String?;
      }

      final file = File(filePath);
      final fileSize = await file.length();

      final recording = AudioRecording(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: widget.studentId,
        storyId: widget.storyId,
        filePath: filePath,
        duration: _recordDuration,
        recordedAt: DateTime.now(),
        fileSize: fileSize,
        storyTitle: storyTitle,
      );

      await db.insertAudioRecording(recording.toMap());
      debugPrint('✅ Ses kaydı veritabanına kaydedildi: $filePath');
    } catch (e) {
      debugPrint('⚠️ Veritabanına kaydetme hatası: $e');
    }
  }

  /// Süreyi formatla (mm:ss)
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.mic,
                color: _isRecording ? Colors.red : AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording
                    ? (_isPaused ? 'Kayıt Duraklatıldı' : 'Kayıt Yapılıyor...')
                    : 'Ses Kaydı',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dalga animasyonu (kayıt sırasında)
          if (_isRecording && !_isPaused)
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final delay = index * 0.2;
                    final value = (_waveAnimation.value + delay) % 1.0;
                    return Container(
                      width: 4,
                      height: 40 * value + 10,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),

          // Süre gösterimi
          if (_isRecording) ...[
            const SizedBox(height: 16),
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Kontrol butonları
          if (!_isRecording)
            // Başlat butonu
            ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Kaydı Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          else
            // Kayıt kontrolleri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // İptal butonu
                IconButton(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.close),
                  iconSize: 32,
                  color: Colors.grey,
                  tooltip: 'İptal Et',
                ),

                // Duraklat/Devam butonu
                IconButton(
                  onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  iconSize: 48,
                  color: AppTheme.primaryColor,
                  tooltip: _isPaused ? 'Devam Et' : 'Duraklat',
                ),

                // Durdur butonu
                IconButton(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  iconSize: 32,
                  color: Colors.red,
                  tooltip: 'Durdur',
                ),
              ],
            ),

          // İzin mesajı
          if (!_hasPermission && !_isRecording) ...[
            const SizedBox(height: 8),
            Text(
              'Ses kaydı için mikrofon izni gereklidir',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _requestPermission,
              child: const Text('İzin Ver'),
            ),
          ],
        ],
      ),
    );
  }
}
