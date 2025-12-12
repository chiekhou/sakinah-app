import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type; // 'article', 'quiz', 'scenario'
  final String theme;
  final VoidCallback onTap;
  final bool isWide;

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.theme,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête coloré avec icône
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(_getEmoji(), style: const TextStyle(fontSize: 48)),
              ),
            ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Titre
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(),

                    // Durée
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (theme) {
      case 'stress':
        return '😰';
      case 'estime':
        return '💪';
      case 'harcelement':
        return '🛡️';
      case 'emotions':
        return '💭';
      case 'sommeil':
        return '😴';
      case 'conflit':
        return '🤝';
      default:
        return type == 'quiz'
            ? '🧠'
            : type == 'scenario'
            ? '🎭'
            : '📰';
    }
  }

  LinearGradient _getGradient() {
    switch (theme) {
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'estime':
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'harcelement':
        return const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'emotions':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sommeil':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case 'quiz':
        return AppTheme.primaryColor;
      case 'article':
        return AppTheme.secondaryColor;
      case 'scenario':
        return AppTheme.accentColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case 'quiz':
        return 'QUIZ';
      case 'article':
        return 'ARTICLE';
      case 'scenario':
        return 'SCÉNARIO';
      default:
        return type.toUpperCase();
    }
  }
}
