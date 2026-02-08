import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'st.services92@gmail.com',
      query: 'subject=Feedback Sakinah App',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          _showEmailDialog(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showEmailDialog(context);
      }
    }
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nous contacter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Envoie-nous un email à :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'st.services92@gmail.com',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Objet : Feedback Sakinah App',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('À propos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Icône de l'app
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Center(
              child: Text(
                'Sakinah',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Ton compagnon bien-être',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 40),

            // Section Notre Mission
            _buildSection(
              icon: Icons.flag_rounded,
              title: 'Notre Mission',
              content:
                  'Sakinah est née d\'une conviction simple : chaque personne mérite '
                  'd\'avoir accès à des outils pour prendre soin de sa santé mentale. '
                  'Cette application a été créée pour t\'accompagner dans les moments '
                  'difficiles comme dans les bons moments, avec bienveillance et sans jugement.',
            ),

            const SizedBox(height: 24),

            // Section Qui suis-je
            _buildSection(
              icon: Icons.person_rounded,
              title: 'Qui suis-je ?',
              content:
                  'Je m\'appelle Chiekhou, et j\'ai créé Sakinah parce que je crois '
                  'qu\'il est essentiel d\'offrir à tout le monde des espaces sûrs pour exprimer '
                  'leurs émotions et trouver du soutien. Cette application est le fruit '
                  'd\'un engagement sincère pour le bien-être de toute personne.',
            ),

            const SizedBox(height: 24),

            // Disclaimer IMPORTANT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: AppTheme.warningColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sakinah est un outil de soutien et d\'accompagnement, mais ne remplace '
                    'en aucun cas l\'avis d\'un professionnel de santé. Si tu traverses une '
                    'période difficile, n\'hésite pas à en parler à un adulte de confiance ou '
                    'à contacter un professionnel.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Numéros d'urgence
            _buildSection(
              icon: Icons.phone_rounded,
              title: 'Besoin d\'aide immédiate ?',
              content:
                  'Si tu es en détresse ou en danger, contacte immédiatement :',
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildEmergencyNumber(
                    'Fil Santé Jeunes',
                    '0 800 235 236',
                    'Gratuit, anonyme, 7j/7',
                  ),
                  const Divider(height: 24),
                  _buildEmergencyNumber(
                    'SOS Amitié',
                    '09 72 39 40 50',
                    'Écoute 24h/24',
                  ),
                  const Divider(height: 24),
                  _buildEmergencyNumber(
                    'Urgences',
                    '15 ou 112',
                    'En cas d\'urgence vitale',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact
            Center(
              child: SoftCard(
                child: InkWell(
                  onTap: () => _launchEmail(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        const Text(
                          'Nous contacter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Fait avec 💚 pour le bien-être des jeunes',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyNumber(String service, String number, String info) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
