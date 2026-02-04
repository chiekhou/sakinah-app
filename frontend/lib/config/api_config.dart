class ApiConfig {
  // URL de base de l'API
  //static const String baseUrl = 'http://localhost:3000/api';

  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Pour tester sur un appareil réel (remplacer par ton IP local)
  // static const String baseUrl = 'http://192.168.1.X:3000/api';

  // Pour production
  // static const String baseUrl = 'https://api.sakinah.app/api';

  // Timeout des requêtes
  static const Duration timeout = Duration(seconds: 30);
}
