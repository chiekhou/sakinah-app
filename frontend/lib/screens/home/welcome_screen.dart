import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

/// Écran de bienvenue avec carrousel
/// Présente les fonctionnalités de l'app de manière inspirante
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.favorite,
      iconColor: AppTheme.primary,
      title: 'Bienvenue sur Sakinah',
      description:
          'Un espace sûr et bienveillant pour prendre soin de ta santé mentale. Tu n\'es pas seul·e.',
      gradient: AppTheme.primaryGradient,
    ),
    OnboardingPage(
      icon: Icons.emoji_emotions,
      iconColor: AppTheme.moodHappy,
      title: 'Exprime tes émotions',
      description:
          'Suivi quotidien de ton humeur, quiz interactifs et exercices pour mieux te comprendre.',
      gradient: const LinearGradient(
        colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    /* OnboardingPage(
      icon: Icons.psychology,
      iconColor: AppTheme.info,
      title: 'Accompagnement professionnel',
      description:
          'Accède à des psychologues et éducateurs vérifiés. Partage ton vécu en toute confidentialité.',
      gradient: AppTheme.skyGradient,
    ),*/
    OnboardingPage(
      icon: Icons.groups,
      iconColor: AppTheme.moodCalm,
      title: 'Communauté bienveillante',
      description:
          'Lis des témoignages, partage ton histoire. Ensemble, on est plus forts.',
      gradient: AppTheme.calmGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppTheme.animationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _getStarted() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bouton Skip en haut à droite
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Passer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            // Carrousel de pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicateurs de page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Boutons de navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_currentPage == _pages.length - 1)
                    PrimaryButton(
                      text: 'Commencer',
                      onPressed: _getStarted,
                      icon: Icons.arrow_forward,
                    )
                  else
                    PrimaryButton(
                      text: 'Suivant',
                      onPressed: _nextPage,
                      icon: Icons.arrow_forward,
                    ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    text: 'J\'ai déjà un compte',
                    onPressed: _skip,
                    icon: Icons.login,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône avec gradient
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: page.gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppTheme.softShadow,
            ),
            child: Icon(page.icon, size: 60, color: Colors.white),
          ),

          const SizedBox(height: 48),

          // Titre
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: AppTheme.animationNormal,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppTheme.primary : AppTheme.textDisabled,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Modèle pour une page d'onboarding
class OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Gradient gradient;

  OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
