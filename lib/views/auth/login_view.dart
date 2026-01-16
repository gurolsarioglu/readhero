import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Giriş ekranı
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = context.read<AuthController>();

    // Giriş işlemi
    final success = await authController.login(
      emailOrPhone: _emailOrPhoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Başarılı - Öğrenci seçim ekranına git
      Navigator.of(context).pushReplacementNamed(AppRoutes.selectStudent);
    } else {
      // Hata göster
      final error = authController.errorMessage ?? 'Giriş başarısız';
      _showError(error);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthController>(
          builder: (context, authController, child) {
            return Stack(
              children: [
                // İçerik
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Logo
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Başlık
                        Text(
                          'Hoş Geldin!',
                          style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Okuma serüvenine devam et',
                          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email veya Telefon
                        CustomTextField(
                          controller: _emailOrPhoneController,
                          label: 'Email veya Telefon',
                          hint: 'ornek@email.com veya 5XX XXX XX XX',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email veya telefon gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Şifre
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          hint: 'Şifrenizi girin',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Beni hatırla ve Şifremi unuttum
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rememberMe = !_rememberMe;
                                    });
                                  },
                                  child: Text(
                                    'Beni Hatırla',
                                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Şifre sıfırlama ekranına git
                                _showError('Şifre sıfırlama yakında eklenecek');
                              },
                              child: Text(
                                'Şifremi Unuttum',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Giriş butonu
                        CustomButton(
                          text: 'Giriş Yap',
                          onPressed: _login,
                          width: double.infinity,
                          isLoading: authController.isLoading,
                        ),
                        const SizedBox(height: 24),

                        // Kayıt ol linki
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hesabın yok mu? ',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.register,
                                );
                              },
                              child: Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Yüklenme göstergesi
                if (authController.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: LoadingIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
