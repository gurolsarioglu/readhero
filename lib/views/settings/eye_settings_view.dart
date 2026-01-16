import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/eye_health_service.dart';

class EyeSettingsView extends StatefulWidget {
  const EyeSettingsView({Key? key}) : super(key: key);

  @override
  State<EyeSettingsView> createState() => _EyeSettingsViewState();
}

class _EyeSettingsViewState extends State<EyeSettingsView> {
  final _eyeHealthService = EyeHealthService.instance;
  
  bool _blinkReminderEnabled = false;
  int _blinkReminderInterval = 20;
  bool _blueLightFilterEnabled = false;
  double _blueLightFilterIntensity = 0.3;
  bool _adaptiveTextEnabled = true;
  double _baseFontSize = 18.0;
  double _lineHeight = 1.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _blinkReminderEnabled = _eyeHealthService.isBlinkReminderEnabled;
      _blinkReminderInterval = _eyeHealthService.blinkReminderInterval;
      _blueLightFilterEnabled = _eyeHealthService.isBlueLightFilterEnabled;
      _blueLightFilterIntensity = _eyeHealthService.blueLightFilterIntensity;
      _adaptiveTextEnabled = _eyeHealthService.isAdaptiveTextEnabled;
      _baseFontSize = _eyeHealthService.baseFontSize;
      _lineHeight = _eyeHealthService.lineHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Göz Sağlığı Ayarları'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetSettings,
            tooltip: 'Varsayılana Dön',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildBlinkReminderSection(),
          const SizedBox(height: 24),
          _buildBlueLightFilterSection(),
          const SizedBox(height: 24),
          _buildAdaptiveTextSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Göz Sağlığı',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Çocuğunuzun göz sağlığını korumak için özel ayarlar',
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkReminderSection() {
    return _buildSection(
      'Göz Kırpma Hatırlatıcısı',
      Icons.remove_red_eye_outlined,
      [
        SwitchListTile(
          title: const Text('Hatırlatıcıyı Aç'),
          subtitle: const Text('20-20-20 kuralı hatırlatması'),
          value: _blinkReminderEnabled,
          onChanged: (value) async {
            setState(() => _blinkReminderEnabled = value);
            await _eyeHealthService.setBlinkReminderEnabled(value);
          },
          activeColor: AppTheme.primaryColor,
        ),
        if (_blinkReminderEnabled) ...[
          const Divider(),
          ListTile(
            title: const Text('Hatırlatma Aralığı'),
            subtitle: Text('$_blinkReminderInterval saniye'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _blinkReminderInterval.toDouble(),
                min: 10,
                max: 60,
                divisions: 10,
                label: '$_blinkReminderInterval sn',
                onChanged: (value) {
                  setState(() => _blinkReminderInterval = value.toInt());
                },
                onChangeEnd: (value) async {
                  await _eyeHealthService.setBlinkReminderInterval(value.toInt());
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBlueLightFilterSection() {
    return _buildSection(
      'Mavi Işık Filtresi',
      Icons.wb_sunny_outlined,
      [
        SwitchListTile(
          title: const Text('Filtreyi Aç'),
          subtitle: const Text('Gece okumalarında göz yorgunluğunu azaltır'),
          value: _blueLightFilterEnabled,
          onChanged: (value) async {
            setState(() => _blueLightFilterEnabled = value);
            await _eyeHealthService.setBlueLightFilterEnabled(value);
          },
          activeColor: AppTheme.primaryColor,
        ),
        if (_blueLightFilterEnabled) ...[
          const Divider(),
          ListTile(
            title: const Text('Filtre Yoğunluğu'),
            subtitle: Text('${(_blueLightFilterIntensity * 100).toInt()}%'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _blueLightFilterIntensity,
                min: 0.1,
                max: 0.7,
                divisions: 12,
                label: '${(_blueLightFilterIntensity * 100).toInt()}%',
                onChanged: (value) {
                  setState(() => _blueLightFilterIntensity = value);
                },
                onChangeEnd: (value) async {
                  await _eyeHealthService.setBlueLightFilterIntensity(value);
                },
                activeColor: Colors.orange,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: _eyeHealthService.blueLightFilterColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                child: Text(
                  'Filtre Önizleme',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdaptiveTextSection() {
    return _buildSection(
      'Adaptif Metin',
      Icons.text_fields,
      [
        SwitchListTile(
          title: const Text('Adaptif Metni Aç'),
          subtitle: const Text('Okuma süresine göre metin boyutu artar'),
          value: _adaptiveTextEnabled,
          onChanged: (value) async {
            setState(() => _adaptiveTextEnabled = value);
            await _eyeHealthService.setAdaptiveTextEnabled(value);
          },
          activeColor: AppTheme.primaryColor,
        ),
        const Divider(),
        ListTile(
          title: const Text('Temel Font Boyutu'),
          subtitle: Text('${_baseFontSize.toInt()} pt'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: _baseFontSize,
              min: 14,
              max: 28,
              divisions: 14,
              label: '${_baseFontSize.toInt()} pt',
              onChanged: (value) {
                setState(() => _baseFontSize = value);
              },
              onChangeEnd: (value) async {
                await _eyeHealthService.setBaseFontSize(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Satır Yüksekliği'),
          subtitle: Text(_lineHeight.toStringAsFixed(1)),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: _lineHeight,
              min: 1.2,
              max: 2.0,
              divisions: 16,
              label: _lineHeight.toStringAsFixed(1),
              onChanged: (value) {
                setState(() => _lineHeight = value);
              },
              onChangeEnd: (value) async {
                await _eyeHealthService.setLineHeight(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Bu bir örnek metindir.\nFont boyutu ve satır yüksekliği ayarlarını test edebilirsiniz.',
              style: TextStyle(
                fontSize: _baseFontSize,
                height: _lineHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılana Dön'),
        content: const Text(
          'Tüm göz sağlığı ayarları varsayılan değerlere dönecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await _eyeHealthService.resetAllSettings();
              _loadSettings();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayarlar sıfırlandı')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}
