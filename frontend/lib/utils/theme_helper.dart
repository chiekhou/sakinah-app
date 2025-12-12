import 'package:flutter/material.dart';

class ThemeHelper {
  /// Obtenir le label avec emoji d'un thème
  static String getThemeLabel(String theme) {
    switch (theme) {
      case 'stress':
        return '😰 Stress';
      case 'estime':
        return '💪 Estime de soi';
      case 'harcelement':
        return '🛡️ Harcèlement';
      case 'emotions':
        return '💭 Émotions';
      case 'sommeil':
        return '😴 Sommeil';
      case 'sante_mentale':
        return '🧠 Santé mentale';
      case 'conflit':
        return '🤝 Conflit';
      default:
        return theme;
    }
  }

  /// Obtenir uniquement l'emoji d'un thème
  static String getThemeEmoji(String theme) {
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
      case 'sante_mentale':
        return '🧠';
      case 'conflit':
        return '🤝';
      default:
        return '📝';
    }
  }

  /// Obtenir le gradient d'un thème
  static LinearGradient getThemeGradient(String theme) {
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
      case 'sante_mentale':
        return const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'conflit':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Liste de tous les thèmes disponibles
  static const List<String> allThemes = [
    'stress',
    'estime',
    'harcelement',
    'emotions',
    'sommeil',
    'sante_mentale',
    'conflit',
  ];
}
