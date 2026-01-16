import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Doğrulama ekranı - Email ve SMS kodu doğrulama
class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final _emailCodeController = TextEditingController();
  final _phoneCodeController = TextEditingController();

  bool _emailVerified = false;
  bool _phoneVerified = false;
  int _emailResendTimer = 0;
  int _phoneResendTimer = 0;
  Timer? _emailTimer;
  Timer? _phoneTimer;

  @override
  void dispose() {
    _emailCodeController.dispose();
    _phoneCodeController.dispose();
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    final code = _emailCodeController.text;
    if (code.length != 6) {
      _showError('Lütfen 6 haneli kodu girin');
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.verifyEmail(code);

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailVerified = true;
        _phoneVerified = true; // SMS geçici olarak otomatik doğrulanıyor
      });
      _showSuccess('Email doğrulandı!');
      
      // Arka planda telefonu da doğrula (senkronizasyon için)
      await authController.verifyPhone('123456');
      
      _checkCompletion();
    } else {
      _showError(authController.errorMessage ?? 'Doğrulama başarısız');
    }
  }

  Future<void> _verifyPhone() async {
    final code = _phoneCodeController.text;
    if (code.length != 6) {
      _showError('Lütfen 6 haneli kodu girin');
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.verifyPhone(code);

    if (!mounted) return;

    if (success) {
      setState(() {
        _phoneVerified = true;
      });
      _showSuccess('Telefon doğrulandı!');
      _checkCompletion();
    } else {
      _showError(authController.errorMessage ?? 'Doğrulama başarısız');
    }
  }

  Future<void> _resendEmailCode() async {
    final authController = context.read<AuthController>();
    final success = await authController.sendEmailVerificationCode();

    if (!mounted) return;

    if (success) {
      _showSuccess('Email kodu gönderildi');
      _startEmailTimer();
    } else {
      _showError(authController.errorMessage ?? 'Kod gönderilemedi');
    }
  }

  Future<void> _resendPhoneCode() async {
    final authController = context.read<AuthController>();
    final success = await authController.sendPhoneVerificationCode();

    if (!mounted) return;

    if (success) {
      _showSuccess('SMS kodu gönderildi');
      _startPhoneTimer();
    } else {
      _showError(authController.errorMessage ?? 'Kod gönderilemedi');
    }
  }

  void _startEmailTimer() {
    setState(() {
      _emailResendTimer = 60;
    });
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_emailResendTimer > 0) {
          _emailResendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _startPhoneTimer() {
    setState(() {
      _phoneResendTimer = 60;
    });
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_phoneResendTimer > 0) {
          _phoneResendTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _checkCompletion() {
    if (_emailVerified && _phoneVerified) {
      // Her ikisi de doğrulandı - Öğrenci ekleme ekranına git
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.addStudent);
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Doğrulama'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Açıklama
              Text(
                'Hesabınızı Doğrulayın',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lütfen e-posta adresinize gönderilen 6 haneli kodu girin.\n(Test için: 123456)',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // Email Doğrulama
              _buildVerificationCard(
                title: 'Email Doğrulama',
                icon: Icons.email_outlined,
                controller: _emailCodeController,
                isVerified: _emailVerified,
                resendTimer: _emailResendTimer,
                onVerify: _verifyEmail,
                onResend: _resendEmailCode,
              ),
              const SizedBox(height: 24),

              // Telefon Doğrulama (Geçici olarak devre dışı)
              /*
              _buildVerificationCard(
                title: 'Telefon Doğrulama',
                icon: Icons.phone_outlined,
                controller: _phoneCodeController,
                isVerified: _phoneVerified,
                resendTimer: _phoneResendTimer,
                onVerify: _verifyPhone,
                onResend: _resendPhoneCode,
              ),
              */
              const SizedBox(height: 40),

              // İlerleme göstergesi
              if (_emailVerified || _phoneVerified)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_emailVerified && _phoneVerified)
                          ? 1.0
                          : 0.5,
                      backgroundColor: AppTheme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (_emailVerified && _phoneVerified)
                          ? '✓ Doğrulama tamamlandı!'
                          : '${_emailVerified || _phoneVerified ? "1" : "0"}/2 doğrulama tamamlandı',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isVerified,
    required int resendTimer,
    required VoidCallback onVerify,
    required VoidCallback onResend,
  }) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isVerified)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.secondaryColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Kod girişi
            if (!isVerified) ...[
              CustomTextField(
                controller: controller,
                label: 'Doğrulama Kodu',
                hint: '6 haneli kod',
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onVerify(),
              ),
              const SizedBox(height: 16),

              // Doğrula butonu
              CustomButton(
                text: 'Doğrula',
                onPressed: onVerify,
                width: double.infinity,
              ),
              const SizedBox(height: 12),

              // Tekrar gönder
              Center(
                child: resendTimer > 0
                    ? Text(
                        'Tekrar gönder ($resendTimer saniye)',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      )
                    : GestureDetector(
                        onTap: onResend,
                        child: Text(
                          'Kodu Tekrar Gönder',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ] else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Doğrulandı ✓',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
