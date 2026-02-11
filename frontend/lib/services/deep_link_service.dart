import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/screens/auth/reset_password_screen.dart';

/// Service pour gérer les deep links (vérification email, reset password, etc.)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // GlobalKey pour accéder au navigateur
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Indique qu'un deep link a navigué avec succès
  static bool hasNavigated = false;

  /// Initialiser le service de deep links
  Future<void> init() async {
    debugPrint('🔗 DeepLinkService: Initialisation...');

    // Gérer le lien initial (app ouverte via un lien)
    try {
      final initialLink = await _appLinks.getInitialLink();
      debugPrint('🔗 DeepLinkService: Lien initial = $initialLink');
      if (initialLink != null) {
        await _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('🔗 DeepLinkService: Erreur récupération lien initial: $e');
    }

    // Écouter les liens entrants (app déjà ouverte)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        debugPrint('🔗 DeepLinkService: Lien entrant = $uri');
        await _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('🔗 DeepLinkService: Erreur stream: $error');
      },
    );

    debugPrint('🔗 DeepLinkService: Initialisation terminée');
  }

  /// Arrêter l'écoute des deep links
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Traiter un deep link
  Future<void> _handleDeepLink(Uri uri) async {
    // PRODUCTION: Logs sensibles désactivés (exposent URI et tokens)
    // debugPrint('🔗 === DEEP LINK REÇU ===');
    // debugPrint('🔗 URI complet: $uri');
    // debugPrint('🔗 Scheme: ${uri.scheme}');
    // debugPrint('🔗 Host: ${uri.host}');
    // debugPrint('🔗 Path: ${uri.path}');
    // debugPrint('🔗 PathSegments: ${uri.pathSegments}');

    String? action;
    String? token;

    // Pour custom scheme: sakinah://verify-email/TOKEN
    // host = "verify-email", path = "/TOKEN" ou pathSegments = ["TOKEN"]
    if (uri.scheme == 'sakinah') {
      action = uri.host; // "verify-email", "reset-password", etc.
      if (uri.pathSegments.isNotEmpty) {
        token = uri.pathSegments.first;
      } else if (uri.path.isNotEmpty && uri.path != '/') {
        token = uri.path.replaceFirst('/', '');
      }
    }
    // Pour https scheme: https://domain.com/verify-email/TOKEN
    // pathSegments = ["verify-email", "TOKEN"]
    else if (uri.scheme == 'https' || uri.scheme == 'http') {
      if (uri.pathSegments.isNotEmpty) {
        action = uri.pathSegments.first;
        if (uri.pathSegments.length > 1) {
          token = uri.pathSegments[1];
        }
      }
    }

    // PRODUCTION: Logs sensibles désactivés (exposent tokens)
    // debugPrint('🔗 Action: $action');
    // debugPrint('🔗 Token: $token');

    if (action == null) {
      debugPrint('🔗 Action non trouvée, abandon');
      return;
    }

    switch (action) {
      case 'verify-email':
        if (token != null && token.isNotEmpty) {
          await _handleEmailVerification(token);
        } else {
          debugPrint('🔗 Token manquant pour verify-email');
          _showMessage('Lien de vérification invalide', isSuccess: false);
        }
        break;

      case 'reset-password':
        if (token != null && token.isNotEmpty) {
          await _navigateToResetPassword(token);
        } else {
          debugPrint('🔗 Token manquant pour reset-password');
          _showMessage('Lien de réinitialisation invalide', isSuccess: false);
        }
        break;

      case 'parental-consent':
        if (token != null && token.isNotEmpty) {
          await _handleParentalConsent(token);
        } else {
          debugPrint('🔗 Token manquant pour parental-consent');
        }
        break;

      default:
        debugPrint('🔗 Action non reconnue: $action');
    }
  }

  /// Vérifier l'email automatiquement
  Future<void> _handleEmailVerification(String token) async {
    // PRODUCTION: Logs sensibles désactivés (exposent token)
    // debugPrint('🔗 === VÉRIFICATION EMAIL ===');
    // debugPrint('🔗 Token: $token');

    try {
      // debugPrint('🔗 Appel API verifyEmail...');
      final result = await ApiService.verifyEmail(token);
      // debugPrint('🔗 Résultat API: $result');

      if (result['success'] == true) {
        debugPrint('🔗 ✅ Email vérifié avec succès!');

        // Afficher le message et attendre que l'utilisateur appuie sur OK
        await _showSuccessAndNavigate(
          'Email vérifié avec succès !\n\nVous pouvez maintenant vous connecter.',
          '/login',
        );
      } else {
        debugPrint('🔗 ❌ Erreur: ${result['error']}');
        _showMessage(result['error'] ?? 'Erreur de vérification', isSuccess: false);
      }
    } catch (e) {
      debugPrint('🔗 ❌ Exception: $e');
      _showMessage('Erreur de connexion au serveur: $e', isSuccess: false);
    }
  }

  /// Naviguer vers la page de reset password avec le token
  Future<void> _navigateToResetPassword(String token) async {
    // PRODUCTION: Log sensible désactivé (expose token)
    // debugPrint('🔗 Navigation reset password avec token: $token');

    // Marquer immédiatement pour empêcher le splash screen de naviguer
    hasNavigated = true;

    // Attendre que le navigator soit prêt (cold start)
    NavigatorState? navigator = navigatorKey.currentState;
    int attempts = 0;
    while (navigator == null && attempts < 50) {
      debugPrint('🔗 Navigator pas encore prêt, attente... (tentative ${attempts + 1})');
      await Future.delayed(const Duration(milliseconds: 100));
      navigator = navigatorKey.currentState;
      attempts++;
    }

    if (navigator != null) {
      debugPrint('🔗 Navigator prêt, navigation vers ResetPasswordScreen');
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token),
        ),
        (route) => false,
      );
    } else {
      debugPrint('🔗 ⚠️ Navigator toujours null après $attempts tentatives');
      hasNavigated = false; // Reset pour permettre au splash screen de prendre le relais
      _showMessage('Erreur de navigation', isSuccess: false);
    }
  }

  /// Gérer le consentement parental
  Future<void> _handleParentalConsent(String token) async {
    // PRODUCTION: Log sensible désactivé (expose token)
    // debugPrint('🔗 Consentement parental avec token: $token');
    _showMessage('Consentement parental en cours de traitement...', isSuccess: true);
  }

  /// Afficher un message de succès et naviguer après que l'utilisateur appuie sur OK
  Future<void> _showSuccessAndNavigate(String message, String route) async {
    debugPrint('🔗 Affichage message succès: $message');

    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('🔗 ⚠️ Context est null');
      return;
    }

    // Afficher le dialog et attendre que l'utilisateur appuie sur OK
    await showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur DOIT appuyer sur OK
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Succès !'),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );

    // Après que l'utilisateur a appuyé sur OK, naviguer
    debugPrint('🔗 Navigation vers $route');
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(route, (route) => false);
    }
  }

  /// Afficher un message (SnackBar ou Dialog)
  void _showMessage(String message, {required bool isSuccess}) {
    debugPrint('🔗 Affichage message: $message');

    final context = navigatorKey.currentContext;
    debugPrint('🔗 Context: $context');

    if (context != null) {
      // Utiliser un Dialog pour être sûr que ça s'affiche
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          icon: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 48,
          ),
          title: Text(isSuccess ? 'Succès' : 'Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      debugPrint('🔗 ⚠️ Context est null, impossible d\'afficher le message');
    }
  }
}
