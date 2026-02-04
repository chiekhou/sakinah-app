import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

/// Écran de profil
/// Affiche différentes options selon l'état de connexion
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return _buildAuthenticatedProfile(context, authProvider);
        } else {
          return _buildAnonymousProfile(context);
        }
      },
    );
  }

  /// Profil pour utilisateur connecté
  Widget _buildAuthenticatedProfile(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final user = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar et infos
            Center(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: user['avatar_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              ApiService.getFullUrl(user['avatar_url']),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Pseudo
                  Text(
                    user['pseudo'] ?? user['username'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user['email'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge de rôle
                  StatusBadge(
                    text: _getRoleLabel(user['role']),
                    color: _getRoleColor(user['role']),
                    icon: _getRoleIcon(user['role']),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Options de menu
            _buildMenuCard(
              context,
              icon: Icons.edit,
              title: 'Modifier mon profil',
              subtitle: 'Pseudo, bio, avatar',
              onTap: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),

            _buildMenuCard(
              context,
              icon: Icons.history,
              title: 'Mon historique',
              subtitle: 'Humeurs, quiz complétés',
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),

            _buildMenuCard(
              context,
              icon: Icons.favorite,
              title: 'Mes témoignages',
              subtitle: 'Partages et likes',
              onTap: () {
                Navigator.pushNamed(context, '/my-testimonials');
              },
            ),

            const SizedBox(height: 16),

            // Bouton À propos
            _buildMenuCard(
              context,
              icon: Icons.info_outline,
              title: 'À propos',
              subtitle: 'En savoir plus sur Sakinah',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),

            // Bouton Soutenir le projet
            _buildMenuCard(
              context,
              icon: Icons.volunteer_activism,
              title: 'Soutenir Sakinah',
              subtitle: 'Aide-nous à grandir',
              onTap: () {
                Navigator.pushNamed(context, '/support');
              },
              isHighlighted: true,
            ),

            const SizedBox(height: 16),

            // Bouton déconnexion
            SecondaryButton(
              text: 'Se déconnecter',
              icon: Icons.logout,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Se déconnecter'),
                    content: const Text(
                      'Es-tu sûr de vouloir te déconnecter ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await authProvider.logout();
                  if (context.mounted) {
                    // Rester sur l'app mais en mode anonyme
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Déconnexion réussie'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Profil pour utilisateur anonyme
  Widget _buildAnonymousProfile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Titre
            const Text(
              'Profite pleinement de Sakinah ! 💚',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Crée un compte pour sauvegarder ton historique, partager tes témoignages et accéder à toutes les fonctionnalités.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Avantages
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avec un compte tu pourras :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefit(
                    Icons.history,
                    'Sauvegarder ton historique d\'humeurs',
                  ),
                  _buildBenefit(
                    Icons.favorite,
                    'Partager et liker des témoignages',
                  ),
                  _buildBenefit(Icons.chat, 'Échanger avec des professionnels'),
                  _buildBenefit(
                    Icons.insights,
                    'Voir ton évolution sur le long terme',
                  ),
                  _buildBenefit(
                    Icons.notifications,
                    'Recevoir des notifications personnalisées',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Boutons
            PrimaryButton(
              text: 'Créer un compte',
              icon: Icons.person_add,
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
            ),

            const SizedBox(height: 16),

            SecondaryButton(
              text: 'J\'ai déjà un compte',
              icon: Icons.login,
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
            ),

            const SizedBox(height: 24),

            // Boutons À propos et Soutenir
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/about');
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('À propos'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/support');
                  },
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: const Text('Soutenir'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu peux continuer à utiliser l\'app sans compte, mais certaines fonctionnalités seront limitées.',
                      style: TextStyle(fontSize: 13, color: AppTheme.info),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final Color accentColor = isHighlighted ? AppTheme.primaryColor : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: isHighlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            )
          : null,
      child: SoftCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isHighlighted ? accentColor : AppTheme.textPrimary,
                        ),
                      ),
                      if (isHighlighted) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: accentColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isHighlighted ? accentColor : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'PSYCHOLOGUE':
        return 'Psychologue';
      case 'EDUCATEUR':
        return 'Éducateur';
      case 'INTERVENANT':
        return 'Intervenant';
      default:
        return 'Utilisateur';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'PSYCHOLOGUE':
        return AppTheme.info;
      case 'EDUCATEUR':
        return AppTheme.moodCalm;
      case 'INTERVENANT':
        return AppTheme.warning;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'PSYCHOLOGUE':
        return Icons.psychology;
      case 'EDUCATEUR':
        return Icons.school;
      case 'INTERVENANT':
        return Icons.work;
      default:
        return Icons.person;
    }
  }
}
