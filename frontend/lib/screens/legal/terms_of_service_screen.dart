import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';

/// Écran des conditions d'utilisation
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
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
                      Icons.description,
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
                          'Règles d\'utilisation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dernière mise à jour : Février 2025',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Acceptation des conditions',
              'En créant un compte ou en utilisant l\'application Sakinah, tu acceptes les présentes '
                  'conditions d\'utilisation. Si tu n\'acceptes pas ces conditions, tu ne dois pas utiliser l\'application.',
            ),

            _buildSection(
              'Description du service',
              'Sakinah est une application de bien-être mental destinée aux jeunes. Elle propose :',
              children: [
                _buildBulletPoint('Un baromètre d\'humeur quotidien'),
                _buildBulletPoint('Des quiz éducatifs sur le bien-être'),
                _buildBulletPoint(
                  'Des articles et scénarios de sensibilisation',
                ),
                _buildBulletPoint('Un espace de témoignages entre pairs'),
                _buildBulletPoint('Un chatbot IA pour le soutien'),
              ],
            ),

            _buildImportantNotice(
              'Sakinah n\'est pas un service médical',
              'Cette application ne remplace pas une consultation avec un professionnel de santé mentale. '
                  'En cas de détresse, contacte un professionnel ou appelle un numéro d\'urgence.',
            ),

            _buildSection(
              'Création de compte',
              null,
              children: [
                _buildBulletPoint(
                  'Tu dois fournir des informations exactes lors de l\'inscription',
                ),
                _buildBulletPoint(
                  'Tu es responsable de la confidentialité de ton mot de passe',
                ),
                _buildBulletPoint('Un seul compte par personne est autorisé'),
                _buildBulletPoint(
                  'Les mineurs doivent avoir le consentement parental',
                ),
              ],
            ),

            _buildSection(
              'Règles de conduite',
              'En utilisant Sakinah, tu t\'engages à :',
              children: [
                _buildBulletPoint('Respecter les autres utilisateurs'),
                _buildBulletPoint(
                  'Ne pas publier de contenu offensant, haineux ou discriminatoire',
                ),
                _buildBulletPoint(
                  'Ne pas harceler ou intimider d\'autres utilisateurs',
                ),
                _buildBulletPoint('Ne pas partager de fausses informations'),
                _buildBulletPoint(
                  'Ne pas usurper l\'identité d\'une autre personne',
                ),
                _buildBulletPoint(
                  'Ne pas utiliser l\'app à des fins illégales',
                ),
              ],
            ),

            _buildSection(
              'Contenu des utilisateurs',
              null,
              children: [
                _buildBulletPoint(
                  'Tu es responsable du contenu que tu publies (témoignages, commentaires)',
                ),
                _buildBulletPoint(
                  'Nous pouvons modérer et supprimer tout contenu inapproprié',
                ),
                _buildBulletPoint(
                  'En publiant du contenu, tu nous accordes le droit de l\'afficher dans l\'application',
                ),
                _buildBulletPoint(
                  'Les témoignages peuvent être anonymes ou pseudonymes',
                ),
              ],
            ),

            _buildSection(
              'Modération',
              'Notre équipe de modération veille au respect des règles. En cas de non-respect :',
              children: [
                _buildBulletPoint(
                  'Avertissement pour une première infraction mineure',
                ),
                _buildBulletPoint('Suppression du contenu inapproprié'),
                _buildBulletPoint('Suspension temporaire du compte'),
                _buildBulletPoint(
                  'Bannissement définitif en cas de récidive grave',
                ),
              ],
            ),

            _buildSection(
              'Propriété intellectuelle',
              'L\'application Sakinah, son design, ses contenus (articles, quiz, scénarios) sont protégés '
                  'par le droit d\'auteur. Tu ne peux pas copier, modifier ou distribuer ces contenus sans autorisation.',
            ),

            _buildSection(
              'Limitation de responsabilité',
              null,
              children: [
                _buildBulletPoint(
                  'L\'application est fournie "en l\'état" sans garantie',
                ),
                _buildBulletPoint(
                  'Nous ne sommes pas responsables des conseils du chatbot IA',
                ),
                _buildBulletPoint(
                  'Nous ne garantissons pas la disponibilité permanente du service',
                ),
                _buildBulletPoint(
                  'Nous ne sommes pas responsables des interactions entre utilisateurs',
                ),
              ],
            ),

            _buildSection(
              'Modifications du service',
              'Nous pouvons modifier, suspendre ou arrêter tout ou partie du service à tout moment. '
                  'Nous t\'informerons des changements majeurs via l\'application ou par email.',
            ),

            /* _buildSection(
              'Résiliation',
              'Tu peux supprimer ton compte à tout moment depuis les paramètres de l\'application. '
                  'Nous pouvons également résilier ton compte en cas de violation des présentes conditions.',
            ),*/
            _buildSection(
              'Droit applicable',
              'Les présentes conditions sont régies par le droit français. '
                  'Tout litige sera soumis aux tribunaux compétents.',
            ),

            _buildSection(
              'Contact',
              'Pour toute question concernant ces conditions, contacte-nous à : st.services92@gmail.com',
            ),

            const SizedBox(height: 32),

            // Pied de page
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'En utilisant Sakinah, tu confirmes avoir lu et accepté ces conditions.',
                      style: TextStyle(fontSize: 13, color: AppTheme.success),
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

  Widget _buildSection(
    String title,
    String? content, {
    List<Widget>? children,
  }) {
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

  Widget _buildBulletPoint(String text) {
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppTheme.warning, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
