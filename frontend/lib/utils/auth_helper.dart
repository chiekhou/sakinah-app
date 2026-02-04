import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';

/// Helper pour vérifier si l'utilisateur est authentifié
/// Affiche un dialogue d'invitation à se connecter si nécessaire
class AuthHelper {
  /// Vérifier si l'utilisateur est connecté
  /// Si non, afficher un dialogue pour l'inviter à se connecter
  /// Retourne true si connecté, false sinon
  static Future<bool> requireAuth(
    BuildContext context, {
    String? message,
    String? feature,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      return true;
    }

    // Utilisateur non connecté → Afficher dialogue
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _AuthRequiredDialog(message: message, feature: feature),
    );

    return result == true;
  }

  /// Afficher un snackbar invitant à se connecter
  static void showLoginPrompt(BuildContext context, {String? feature}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feature != null
              ? 'Connecte-toi pour $feature'
              : 'Connecte-toi pour accéder à cette fonctionnalité',
        ),
        action: SnackBarAction(
          label: 'Se connecter',
          onPressed: () {
            Navigator.of(context).pushNamed('/login');
          },
        ),
        backgroundColor: AppTheme.info,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Dialogue demandant à l'utilisateur de se connecter
class _AuthRequiredDialog extends StatelessWidget {
  final String? message;
  final String? feature;

  const _AuthRequiredDialog({this.message, this.feature});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lock_person,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Titre
            Text(
              feature != null ? 'Connexion requise' : 'Crée un compte',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message ??
                  (feature != null
                      ? 'Pour $feature, tu dois être connecté.'
                      : 'Pour accéder à cette fonctionnalité, tu dois créer un compte ou te connecter.'),
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Bouton Se connecter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton Créer un compte
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  Navigator.of(context).pushNamed('/register');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton Plus tard
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Plus tard'),
            ),
          ],
        ),
      ),
    );
  }
}
