import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';

/// Écran de politique de confidentialité
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ta vie privée compte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dernière mise à jour : Février 2025',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Introduction',
              'Sakinah est une application dédiée au bien-être mental des jeunes. '
                  'Nous prenons très au sérieux la protection de tes données personnelles. '
                  'Cette politique explique comment nous collectons, utilisons et protégeons tes informations.',
            ),

            _buildSection(
              'Données que nous collectons',
              null,
              children: [
                _buildBulletPoint(
                  'Informations de compte',
                  'Nom d\'utilisateur, email, mot de passe (chiffré), tranche d\'âge, rôle',
                ),
                _buildBulletPoint(
                  'Données de profil',
                  'Photo de profil, bio (optionnels)',
                ),
                _buildBulletPoint(
                  'Données d\'utilisation',
                  'Historique d\'humeurs, quiz complétés, témoignages partagés',
                ),
                _buildBulletPoint(
                  'Données techniques',
                  'Token de notification push pour t\'envoyer des rappels',
                ),
              ],
            ),

            _buildSection(
              'Pourquoi nous collectons ces données',
              null,
              children: [
                _buildBulletPoint(
                  'Fournir le service',
                  'Permettre la connexion, sauvegarder ton historique d\'humeurs',
                ),
                _buildBulletPoint(
                  'Personnaliser l\'expérience',
                  'Adapter le contenu selon ton âge et tes besoins',
                ),
                _buildBulletPoint(
                  'Améliorer l\'application',
                  'Comprendre comment l\'app est utilisée pour l\'améliorer',
                ),
                _buildBulletPoint(
                  'Te contacter',
                  'T\'envoyer des notifications de rappel bien-être (si tu l\'acceptes)',
                ),
              ],
            ),

            _buildSection(
              'Protection des mineurs',
              'Si tu as moins de 18 ans, nous demandons le consentement de ton parent ou tuteur légal. '
                  'Nous ne partageons jamais les données des mineurs avec des tiers à des fins commerciales. '
                  'Les témoignages des mineurs sont soumis à une modération renforcée.',
            ),

            _buildSection(
              'Partage des données',
              'Nous ne vendons jamais tes données personnelles. Nous pouvons partager des informations avec :',
              children: [
                _buildBulletPoint(
                  'Prestataires techniques',
                  'Hébergement sécurisé, service d\'envoi d\'emails (Brevo)',
                ),
                _buildBulletPoint(
                  'Autorités légales',
                  'Uniquement si la loi l\'exige',
                ),
              ],
            ),

            _buildSection(
              'Sécurité des données',
              'Nous utilisons des mesures de sécurité avancées pour protéger tes données :',
              children: [
                _buildBulletPoint(
                  'Chiffrement',
                  'Tes mots de passe sont chiffrés et ne sont jamais stockés en clair',
                ),
                _buildBulletPoint(
                  'Connexion sécurisée',
                  'Toutes les communications utilisent HTTPS',
                ),
                _buildBulletPoint(
                  'Accès limité',
                  'Seules les personnes autorisées peuvent accéder aux données',
                ),
              ],
            ),

            _buildSection(
              'Tes droits',
              'Conformément au RGPD et aux lois applicables, tu as le droit de :',
              children: [
                _buildBulletPoint(
                  'Accéder',
                  'Demander une copie de tes données personnelles',
                ),
                _buildBulletPoint(
                  'Rectifier',
                  'Corriger tes informations inexactes',
                ),
                _buildBulletPoint(
                  'Supprimer',
                  'Demander la suppression de ton compte et de tes données',
                ),
                _buildBulletPoint(
                  'Portabilité',
                  'Récupérer tes données dans un format lisible',
                ),
              ],
            ),

            _buildSection(
              'Conservation des données',
              'Nous conservons tes données tant que ton compte est actif. '
                  'Si tu supprimes ton compte, tes données personnelles seront effacées dans un délai de 30 jours. '
                  'Certaines données anonymisées peuvent être conservées à des fins statistiques.',
            ),

            _buildSection(
              'Cookies et technologies similaires',
              'L\'application mobile n\'utilise pas de cookies. Nous utilisons uniquement le stockage local '
                  'de ton appareil pour sauvegarder tes préférences et ton token de connexion.',
            ),

            _buildSection(
              'Modifications de cette politique',
              'Nous pouvons mettre à jour cette politique de confidentialité. '
                  'En cas de changement important, nous t\'en informerons via l\'application ou par email.',
            ),

            _buildSection(
              'Nous contacter',
              'Pour toute question concernant tes données personnelles ou cette politique, '
                  'tu peux nous contacter à : contact@sakinah-app.com',
            ),

            const SizedBox(height: 32),

            // Pied de page
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'En utilisant Sakinah, tu acceptes cette politique de confidentialité.',
                      style: TextStyle(fontSize: 13, color: AppTheme.info),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? content, {List<Widget>? children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$title : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
