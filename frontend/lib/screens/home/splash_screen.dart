import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/screens/auth/reset_password_screen.dart';
import 'package:sakinah_app/screens/parent/parent_confirmation_screen.dart';
import 'package:sakinah_app/services/deep_link_service.dart';

/// Écran de splash - Premier écran affiché au lancement
/// Animation douce et accueillante pour inspirer confiance
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Démarrer l'animation
    _controller.forward();

    // Initialiser l'authentification et naviguer
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Attendre que l'animation soit terminée
    await Future.delayed(const Duration(milliseconds: 6000));

    if (!mounted) return;

    // Si un token de reset password est en attente, naviguer directement
    if (DeepLinkService.pendingResetToken != null) {
      final token = DeepLinkService.pendingResetToken!;
      DeepLinkService.pendingResetToken = null;
      DeepLinkService.hasNavigated = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token),
        ),
        (route) => false,
      );
      return;
    }

    // Si un token de consentement est en attente, naviguer directement
    if (DeepLinkService.pendingConsentToken != null) {
      final token = DeepLinkService.pendingConsentToken!;
      DeepLinkService.pendingConsentToken = null;
      DeepLinkService.hasNavigated = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ParentConfirmationScreen(token: token),
        ),
        (route) => false,
      );
      return;
    }

    // Si un deep link a déjà navigué, ne pas écraser
    if (DeepLinkService.hasNavigated) {
      debugPrint('🔗 Deep link a déjà navigué, splash screen ne redirige pas');
      return;
    }

    // Initialiser le provider d'authentification
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (!mounted) return;

    // Si utilisateur connecté, vérifier son statut
    if (authProvider.isAuthenticated) {
      if (authProvider.needsDiplomaUpload) {
        Navigator.of(context).pushReplacementNamed('/upload-diploma');
      } else if (authProvider.awaitingAdminApproval) {
        Navigator.of(context).pushReplacementNamed('/awaiting-approval');
      } else {
        // Utilisateur connecté et vérifié → Aller au baromètre d'humeur
        Navigator.of(context).pushReplacementNamed('/mood-navigator');
      }
    } else {
      // Utilisateur non connecté → Aller directement au baromètre d'humeur (mode anonyme)
      Navigator.of(context).pushReplacementNamed('/mood-navigator');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animé
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Nom de l'app
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Sakinah',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Viens préserver ton bien-être face au harcèlement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Indicateur de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
