import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // URL de base de l'API - chargée depuis .env.development ou .env.production
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

    // En production, retourner l'URL telle quelle
    if (isProduction) return url;

    // En développement, adapter l'URL selon la plateforme
    if (!kIsWeb && url.contains('localhost')) {
      if (Platform.isAndroid) {
        // Android Emulator utilise 10.0.2.2 pour accéder à localhost
        return url.replaceAll('localhost', '10.0.2.2');
      }
      // iOS Simulator peut utiliser localhost directement
    }

    return url;
  }

  // Environnement actuel
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  // Vérifier si on est en production
  static bool get isProduction => environment == 'production';

  // Timeout des requêtes
  static const Duration timeout = Duration(seconds: 30);

  // Pour debug : afficher la config actuelle
  static void printConfig() {
    debugPrint('=== API Config ===');
    debugPrint('Environment: $environment');
    debugPrint('Base URL: $baseUrl');
    debugPrint('Is Production: $isProduction');
    if (!kIsWeb) {
      debugPrint('Platform: ${Platform.operatingSystem}');
    }
    debugPrint('==================');
  }
}
