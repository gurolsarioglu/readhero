import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/sound_effects_service.dart';

/// Ses efektleri ayarları sayfası
class SoundSettingsView extends StatefulWidget {
  const SoundSettingsView({super.key});

  @override
  State<SoundSettingsView> createState() => _SoundSettingsViewState();
}

class _SoundSettingsViewState extends State<SoundSettingsView> {
  final _soundService = SoundEffectsService();
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = _soundService.isSoundEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Ayarları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ana ses ayarı
          Card(
            child: SwitchListTile(
              title: const Text(
                'Ses Efektleri',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Uygulama seslerini ve titreşimleri aç/kapat',
              ),
              value: _soundEnabled,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) async {
                await _soundService.setSoundEnabled(value);
                setState(() => _soundEnabled = value);
                
                // Test sesi çal
                if (value) {
                  await _soundService.playSuccess();
                }
              },
              secondary: Icon(
                _soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ses efektlerini test et bölümü
          if (_soundEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Ses Efektlerini Test Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Test butonları
            _buildTestButton(
              'Buton Tıklama',
              Icons.touch_app,
              Colors.blue,
              () => _soundService.playButtonClick(),
            ),
            _buildTestButton(
              'Başarı Sesi',
              Icons.check_circle,
              Colors.green,
              () => _soundService.playSuccess(),
            ),
            _buildTestButton(
              'Hata Sesi',
              Icons.error,
              Colors.red,
              () => _soundService.playError(),
            ),
            _buildTestButton(
              'Rozet Kazanma',
              Icons.emoji_events,
              Colors.amber,
              () => _soundService.playBadgeEarned(),
            ),
            _buildTestButton(
              'Puan Kazanma',
              Icons.stars,
              Colors.purple,
              () => _soundService.playPointsEarned(),
            ),
            _buildTestButton(
              'Seviye Atlama',
              Icons.trending_up,
              Colors.orange,
              () => _soundService.playLevelUp(),
            ),
            _buildTestButton(
              'Hedef Tamamlama',
              Icons.flag,
              Colors.teal,
              () => _soundService.playGoalCompleted(),
            ),
            _buildTestButton(
              'Okuma Başlama',
              Icons.play_arrow,
              Colors.indigo,
              () => _soundService.playReadingStart(),
            ),
            _buildTestButton(
              'Okuma Bitirme',
              Icons.stop,
              Colors.pink,
              () => _soundService.playReadingComplete(),
            ),
            _buildTestButton(
              'Doğru Cevap',
              Icons.check,
              Colors.lightGreen,
              () => _soundService.playCorrectAnswer(),
            ),
            _buildTestButton(
              'Yanlış Cevap',
              Icons.close,
              Colors.deepOrange,
              () => _soundService.playWrongAnswer(),
            ),
          ],

          const SizedBox(height: 24),

          // Bilgi kartı
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ses efektleri, uygulamayı daha eğlenceli hale getirir. '
                      'Cihazınızın sesli mod veya titreşim modunda olduğundan emin olun.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Test butonu oluştur
  Widget _buildTestButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Test Et'),
        ),
      ),
    );
  }
}
