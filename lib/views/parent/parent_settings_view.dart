import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_routes.dart';

class ParentSettingsView extends StatefulWidget {
  const ParentSettingsView({Key? key}) : super(key: key);

  @override
  State<ParentSettingsView> createState() => _ParentSettingsViewState();
}

class _ParentSettingsViewState extends State<ParentSettingsView> {
  bool _notificationsEnabled = true;
  bool _eyeBreakReminders = true;
  bool _dailyReports = true;
  bool _weeklyReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Profil',
            Icons.person_outline,
            [
              _buildListTile(
                'Profil Bilgileri',
                'Adınızı ve iletişim bilgilerinizi düzenleyin',
                Icons.edit_outlined,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek')),
                  );
                },
              ),
              _buildListTile(
                'Şifre Değiştir',
                'Hesap şifrenizi güncelleyin',
                Icons.lock_outline,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Öğrenci Yönetimi',
            Icons.school_outlined,
            [
              _buildListTile(
                'Öğrencilerim',
                'Öğrenci ekle, düzenle veya sil',
                Icons.people_outline,
                () {
                  Navigator.pushNamed(context, '/student-management');
                },
              ),
              _buildListTile(
                'Ödül Yönetimi',
                'Öğrencileriniz için ödüller oluşturun',
                Icons.card_giftcard_outlined,
                () {
                  Navigator.pushNamed(context, '/reward-management');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Bildirimler',
            Icons.notifications_outlined,
            [
              _buildSwitchTile(
                'Bildirimleri Aç',
                'Tüm bildirimleri etkinleştir',
                _notificationsEnabled,
                (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              _buildSwitchTile(
                'Göz Molası Hatırlatıcıları',
                '20-20-20 kuralı bildirimleri',
                _eyeBreakReminders,
                (value) {
                  setState(() => _eyeBreakReminders = value);
                },
                enabled: _notificationsEnabled,
              ),
              _buildSwitchTile(
                'Günlük Raporlar',
                'Her gün sonunda özet rapor',
                _dailyReports,
                (value) {
                  setState(() => _dailyReports = value);
                },
                enabled: _notificationsEnabled,
              ),
              _buildSwitchTile(
                'Haftalık Raporlar',
                'Her hafta sonu detaylı rapor',
                _weeklyReports,
                (value) {
                  setState(() => _weeklyReports = value);
                },
                enabled: _notificationsEnabled,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Gizlilik',
            Icons.privacy_tip_outlined,
            [
              _buildListTile(
                'Gizlilik Politikası',
                'Veri kullanım politikamızı görüntüleyin',
                Icons.description_outlined,
                () {
                  _showPrivacyPolicy();
                },
              ),
              _buildListTile(
                'Kullanım Koşulları',
                'Hizmet şartlarımızı okuyun',
                Icons.gavel_outlined,
                () {
                  _showTermsOfService();
                },
              ),
              _buildListTile(
                'Verilerim',
                'Verilerinizi indirin veya silin',
                Icons.download_outlined,
                () {
                  _showDataManagement();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Uygulama',
            Icons.info_outline,
            [
              _buildListTile(
                'Hakkında',
                'ReadHero v1.0.0',
                Icons.info_outlined,
                () {
                  _showAboutDialog();
                },
              ),
              _buildListTile(
                'Yardım & Destek',
                'SSS ve iletişim',
                Icons.help_outline,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDangerZone(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
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
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.captionStyle,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundColor: enabled
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.textSecondary.withOpacity(0.1),
        child: Icon(
          Icons.notifications_active_outlined,
          color: enabled ? AppTheme.primaryColor : AppTheme.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.captionStyle.copyWith(
          color: enabled ? AppTheme.textSecondary : AppTheme.textSecondary.withOpacity(0.5),
        ),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.warning_outlined, size: 20, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              Text(
                'Tehlikeli Bölge',
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  child: Icon(Icons.logout, color: AppTheme.errorColor, size: 20),
                ),
                title: Text(
                  'Çıkış Yap',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
                ),
                subtitle: Text(
                  'Hesabınızdan çıkış yapın',
                  style: AppTheme.captionStyle,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _confirmLogout,
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  child: Icon(Icons.delete_forever, color: AppTheme.errorColor, size: 20),
                ),
                title: Text(
                  'Hesabı Sil',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
                ),
                subtitle: Text(
                  'Tüm verileriniz kalıcı olarak silinecek',
                  style: AppTheme.captionStyle,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: const SingleChildScrollView(
          child: Text(
            'ReadHero olarak kullanıcı gizliliğini çok önemsiyoruz.\n\n'
            '• Verileriniz sadece yerel cihazınızda saklanır\n'
            '• Üçüncü taraflarla paylaşılmaz\n'
            '• İstediğiniz zaman silebilirsiniz\n\n'
            'Detaylı bilgi için: privacy@readhero.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanım Koşulları'),
        content: const SingleChildScrollView(
          child: Text(
            'ReadHero uygulamasını kullanarak aşağıdaki koşulları kabul etmiş olursunuz:\n\n'
            '• Uygulama eğitim amaçlıdır\n'
            '• İçerikler telif haklarına tabidir\n'
            '• Kötüye kullanım yasaktır\n\n'
            'Detaylı bilgi için: terms@readhero.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showDataManagement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Yönetimi'),
        content: const Text(
          'Verilerinizi indirmek veya silmek için lütfen bizimle iletişime geçin.\n\n'
          'E-posta: support@readhero.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ReadHero',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.menu_book, size: 48, color: AppTheme.primaryColor),
      children: [
        const Text(
          'ReadHero, çocukların okuma becerilerini geliştirmek için tasarlanmış '
          'eğitici bir mobil uygulamadır.\n\n'
          '© 2026 ReadHero. Tüm hakları saklıdır.',
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthController>().logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz?\n\n'
          'Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son Onay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesabınızı silmek için lütfen "SİL" yazın:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'SİL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text == 'SİL') {
                Navigator.pop(context);
                final success = await context.read<AuthController>().deleteAccount();
                if (success && mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hesabınız başarıyla silindi')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen "SİL" yazın')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
