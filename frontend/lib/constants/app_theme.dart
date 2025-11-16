import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF6B4CE6); // Violet doux
  static const Color secondaryColor = Color(0xFF50C878); // Vert menthe
  static const Color accentColor = Color(0xFFFFB347); // Orange pastel
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;

  // Couleurs d'humeur
  static const Map<int, Color> moodColors = {
    1: Color(0xFF8B5A8E), // Très mal - Violet foncé
    2: Color(0xFF9B7AA8), // Mal - Violet moyen
    3: Color(0xFFB8A5C6), // Pas top - Violet clair
    4: Color(0xFFA8C5E3), // Neutre - Bleu clair
    5: Color(0xFF95D5B2), // Bien - Vert clair
    6: Color(0xFF74C69D), // Très bien - Vert
    7: Color(0xFF52B788), // Excellent - Vert vif
  };

  // Texte
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Cartes
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Boutons texte
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
    ),

    // Icônes
    iconTheme: const IconThemeData(color: textPrimary, size: 24),
  );

  // Méthode helper pour obtenir la couleur selon l'humeur
  static Color getMoodColor(int moodLevel) {
    return moodColors[moodLevel] ?? Colors.grey;
  }

  // Méthode helper pour obtenir l'emoji selon l'humeur
  static String getMoodEmoji(int moodLevel) {
    const Map<int, String> moodEmojis = {
      1: '😢',
      2: '😔',
      3: '😕',
      4: '😐',
      5: '🙂',
      6: '😊',
      7: '😄',
    };
    return moodEmojis[moodLevel] ?? '😐';
  }

  // Méthode helper pour obtenir le label selon l'humeur
  static String getMoodLabel(int moodLevel) {
    const Map<int, String> moodLabels = {
      1: 'Très mal',
      2: 'Mal',
      3: 'Pas top',
      4: 'Neutre',
      5: 'Bien',
      6: 'Très bien',
      7: 'Excellent',
    };
    return moodLabels[moodLevel] ?? 'Neutre';
  }
}
