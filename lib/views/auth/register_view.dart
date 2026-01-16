import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Kayıt ekranı - Veli kaydı
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Şartları kabul etme kontrolü
    if (!_acceptTerms) {
      _showError('Lütfen kullanım şartlarını kabul edin');
      return;
    }

    final authController = context.read<AuthController>();

    // Kayıt işlemi
    final success = await authController.register(
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );

    if (!mounted) return;

    if (success) {
      // Başarılı - Doğrulama ekranına git
      Navigator.of(context).pushReplacementNamed(AppRoutes.verification);
    } else {
      // Hata göster
      final error = authController.errorMessage ?? 'Kayıt başarısız';
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
                        const SizedBox(height: 20),
                        // Başlık
                        Text(
                          'Hesap Oluştur',
                          style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Çocuğunuzun okuma serüvenine başlayın',
                          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // İsim
                        CustomTextField(
                          controller: _nameController,
                          label: 'Ad Soyad',
                          hint: 'Ahmet Yılmaz',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'İsim gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'ornek@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email gerekli';
                            }
                            if (!value.contains('@')) {
                              return 'Geçersiz email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Telefon
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Telefon',
                          hint: '5XX XXX XX XX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Telefon gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Şifre
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Şifre',
                          hint: 'En az 6 karakter',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
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
                            if (value.length < 6) {
                              return 'En az 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Şifre tekrar
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Şifre Tekrar',
                          hint: 'Şifrenizi tekrar girin',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          suffixIcon: _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onSuffixIconPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Şifre tekrarı gerekli';
                            }
                            if (value != _passwordController.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Kullanım şartları
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptTerms = !_acceptTerms;
                                  });
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Kullanım şartlarını ve gizlilik politikasını kabul ediyorum',
                                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Kayıt butonu
                        CustomButton(
                          text: 'Kayıt Ol',
                          onPressed: _register,
                          width: double.infinity,
                          isLoading: authController.isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Giriş yap linki
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten hesabın var mı? ',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.login,
                                );
                              },
                              child: Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
