import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/audio_recording.dart';

/// Ses kayıtları görüntüleme sayfası (Veli paneli)
/// 1. sınıf öğrencilerinin ses kayıtlarını dinleme
class AudioRecordingsView extends StatefulWidget {
  final String studentId;

  const AudioRecordingsView({
    super.key,
    required this.studentId,
  });

  @override
  State<AudioRecordingsView> createState() => _AudioRecordingsViewState();
}

class _AudioRecordingsViewState extends State<AudioRecordingsView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<AudioRecording> _recordings = [];
  bool _isLoading = true;
  String? _playingRecordingId;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Audio player'ı ayarla
  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _playingRecordingId = null;
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  /// Kayıtları yükle
  Future<void> _loadRecordings() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;
      
      // Ses kayıtlarını getir
      final maps = await db.query(
        'audio_recordings',
        where: 'student_id = ?',
        whereArgs: [widget.studentId],
        orderBy: 'recorded_at DESC',
      );

      _recordings = maps.map((map) => AudioRecording.fromMap(map)).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Kayıtlar yüklenirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Kaydı oynat/duraklat
  Future<void> _togglePlayback(AudioRecording recording) async {
    try {
      if (_playingRecordingId == recording.id && _isPlaying) {
        // Duraklatma
        await _audioPlayer.pause();
      } else if (_playingRecordingId == recording.id && !_isPlaying) {
        // Devam ettirme
        await _audioPlayer.resume();
      } else {
        // Yeni kayıt oynat
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(recording.filePath));
        setState(() {
          _playingRecordingId = recording.id;
        });
      }
    } catch (e) {
      debugPrint('Oynatma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oynatma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Kaydı durdur
  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _playingRecordingId = null;
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
  }

  /// Kaydı sil
  Future<void> _deleteRecording(AudioRecording recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu ses kaydını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Oynatılıyorsa durdur
      if (_playingRecordingId == recording.id) {
        await _stopPlayback();
      }

      // Veritabanından sil
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'audio_recordings',
        where: 'id = ?',
        whereArgs: [recording.id],
      );

      // Dosyayı sil
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Listeyi güncelle
      await _loadRecordings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Silme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Süreyi formatla
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Kayıtları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecordings,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recordings.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // İstatistikler
                    _buildStats(),
                    
                    // Kayıt listesi
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadRecordings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _recordings.length,
                          itemBuilder: (context, index) {
                            return _buildRecordingCard(_recordings[index]);
                          },
                        ),
                      ),
                    ),

                    // Oynatma kontrolleri (eğer bir kayıt oynatılıyorsa)
                    if (_playingRecordingId != null)
                      _buildPlaybackControls(),
                  ],
                ),
    );
  }

  /// İstatistikler
  Widget _buildStats() {
    final totalRecordings = _recordings.length;
    final totalDuration = _recordings.fold<int>(
      0,
      (sum, recording) => sum + recording.duration,
    );
    final totalSize = _recordings.fold<int>(
      0,
      (sum, recording) => sum + recording.fileSize,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.mic,
            '$totalRecordings',
            'Kayıt',
          ),
          _buildStatItem(
            Icons.timer,
            _formatDuration(Duration(seconds: totalDuration)),
            'Toplam Süre',
          ),
          _buildStatItem(
            Icons.storage,
            '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
            'Depolama',
          ),
        ],
      ),
    );
  }

  /// İstatistik öğesi
  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Kayıt kartı
  Widget _buildRecordingCard(AudioRecording recording) {
    final isPlaying = _playingRecordingId == recording.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isPlaying ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPlaying
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve tarih
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.storyTitle ?? 'Hikaye',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
                            .format(recording.recordedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sil butonu
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _deleteRecording(recording),
                  tooltip: 'Sil',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bilgiler
            Row(
              children: [
                _buildInfoChip(
                  Icons.timer,
                  recording.formattedDuration,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.storage,
                  recording.formattedFileSize,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.signal_cellular_alt,
                  recording.qualityIndicator,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Oynat butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _togglePlayback(recording),
                icon: Icon(
                  isPlaying && _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  isPlaying && _isPlaying ? 'Duraklat' : 'Oynat',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  foregroundColor: isPlaying ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bilgi chip'i
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Oynatma kontrolleri
  Widget _buildPlaybackControls() {
    final currentRecording = _recordings.firstWhere(
      (r) => r.id == _playingRecordingId,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İlerleme çubuğu
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _totalDuration.inSeconds.toDouble(),
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          // Kontrol butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () async {
                  final newPosition = _currentPosition - const Duration(seconds: 10);
                  await _audioPlayer.seek(
                    newPosition.isNegative ? Duration.zero : newPosition,
                  );
                },
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
                onPressed: () => _togglePlayback(currentRecording),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () async {
                  final newPosition = _currentPosition + const Duration(seconds: 10);
                  await _audioPlayer.seek(
                    newPosition > _totalDuration ? _totalDuration : newPosition,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stopPlayback,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Boş durum
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ses kaydı yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Öğrenciniz okuma yaparken ses kaydı yapabilir',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
