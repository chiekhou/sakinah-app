import 'package:flutter/material.dart';

/// Thème complet de l'application Sakinah
/// Basé sur le vert espoir #2ECC71 - Symbolisant la croissance, l'espoir et le bien-être
class AppTheme {
  // ==================== COULEURS PRINCIPALES ====================

  /// Vert principal - Espoir, croissance, sérénité
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58D68D);
  static const Color primaryDark = Color(0xFF27AE60);

  // Alias pour compatibilité avec l'ancien code
  static const Color primaryColor = primary;
  static const Color primaryLightColor = primaryLight;
  static const Color primaryDarkColor = primaryDark;
  static const Color secondaryColor = Color(0xFF3498DB);
  static const Color accentColor = Color(0xFFF39C12);

  /// Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundColor = background;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardColor = surface;
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  /// Texte
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);
  static const Color textLight = textDisabled;
  static const Color textOnPrimary = Colors.white;

  // ==================== COULEURS D'ÉTAT ====================

  /// Succès
  static const Color success = Color(0xFF2ECC71);
  static const Color successColor = success;
  static const Color successLight = Color(0xFFD5F4E6);

  /// Erreur
  static const Color error = Color(0xFFE74C3C);
  static const Color errorColor = error;
  static const Color errorLight = Color(0xFFFDEDED);

  /// Attention
  static const Color warning = Color(0xFFF39C12);
  static const Color warningColor = warning;
  static const Color warningLight = Color(0xFFFEF5E7);

  /// Information
  static const Color info = Color(0xFF3498DB);
  static const Color infoColor = info;
  static const Color infoLight = Color(0xFFEBF5FB);

  // ==================== COULEURS PAR HUMEUR ====================

  /// Couleurs d'humeur (échelle 1-7)
  static const Map<int, Color> moodColors = {
    1: Color(0xFF8B5A8E), // Très mal - Violet foncé
    2: Color(0xFF9B7AA8), // Mal - Violet moyen
    3: Color(0xFFB8A5C6), // Pas top - Violet clair
    4: Color(0xFFA8C5E3), // Neutre - Bleu clair
    5: Color(0xFF95D5B2), // Bien - Vert clair
    6: Color(0xFF52B788), // Très bien - Vert
    7: Color(0xFF2ECC71), // Excellent - Vert vif
  };

  /// Humeurs spécifiques
  static const Color moodHappy = Color(0xFFF1C40F);
  static const Color moodSad = Color(0xFF3498DB);
  static const Color moodAngry = Color(0xFFE74C3C);
  static const Color moodAnxious = Color(0xFF9B59B6);
  static const Color moodCalm = Color(0xFF1ABC9C);

  // ==================== DÉGRADÉS ====================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== OMBRES ====================

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== THÈME MATERIAL ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Couleurs
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: primary.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Typographie
      textTheme: const TextTheme(
        // Titres
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Poppins',
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Poppins',
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
          height: 1.3,
        ),

        // Titres de section
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
        ),

        // Corps de texte
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          fontFamily: 'Poppins',
          height: 1.5,
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Poppins',
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Poppins',
        ),
      ),

      // Icônes
      iconTheme: const IconThemeData(color: textPrimary, size: 24),

      // Divider
      dividerTheme: DividerThemeData(
        color: textDisabled.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontFamily: 'Poppins',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Poppins',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
      ),

      // Font family par défaut
      fontFamily: 'Poppins',
    );
  }

  // ==================== DIMENSIONS ====================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ==================== ANIMATIONS ====================

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ==================== MÉTHODES HELPERS ====================

  /// Obtenir la couleur selon l'humeur (échelle 1-7)
  static Color getMoodColor(int moodLevel) {
    return moodColors[moodLevel] ?? Colors.grey;
  }

  /// Obtenir l'emoji selon l'humeur (échelle 1-7)
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

  /// Obtenir le label selon l'humeur (échelle 1-7)
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
