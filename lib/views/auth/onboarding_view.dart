import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Onboarding ekranı - Uygulama tanıtımı (3 sayfa)
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.menu_book_rounded,
      title: 'Okuma Alışkanlığı Kazan',
      description:
          'Çocuğunuz eğlenceli hikayelerle okuma alışkanlığı kazanır. AI destekli içeriklerle sınıf seviyesine uygun hikayeler.',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      icon: Icons.timer_outlined,
      title: 'Okuma Hızını Ölç',
      description:
          'Okuma hızını ve okuduğunu anlama seviyesini takip et. Detaylı raporlarla gelişimi gör.',
      color: AppTheme.secondaryColor,
    ),
    OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Ödül Kazan, Motive Ol',
      description:
          'Puan topla, rozet kazan, ödüllere ulaş! Gamification ile okuma keyifli bir oyuna dönüşür.',
      color: AppTheme.accentColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Son sayfadaysa kayıt ekranına git
      Navigator.of(context).pushReplacementNamed(AppRoutes.register);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Üst bar - Atla butonu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Atla',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Sayfa içeriği
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Alt bar - Göstergeler ve buton
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Sayfa göstergeleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // İleri/Başla butonu
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Başla'
                        : 'İleri',
                    onPressed: _nextPage,
                    width: double.infinity,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // İkon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          // Başlık
          Text(
            page.title,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Açıklama
          Text(
            page.description,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Onboarding sayfa modeli
class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
