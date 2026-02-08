import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah_app/config/api_config.dart';
import 'package:sakinah_app/providers/mood_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer toutes les communications avec l'API backend
class ApiService {
  // URL de base de l'API - chargée depuis ApiConfig (via .env)
  static String get baseUrl => ApiConfig.baseUrl;
  static String get serverUrl => ApiConfig.baseUrl;

  // Clés pour le stockage local
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Construire une URL complète à partir d'un chemin relatif
  /// Ex: '/uploads/avatars/image.png' -> 'http://localhost:3000/uploads/avatars/image.png'
  static String getFullUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    // Si l'URL est déjà complète (commence par http:// ou https://), la retourner telle quelle
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Sinon, construire l'URL complète
    return '$serverUrl$relativePath';
  }

  // ==================== GESTION DU TOKEN ====================

  /// Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Supprimer le token (déconnexion)
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Sauvegarder les données utilisateur
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user));
  }

  /// Récupérer les données utilisateur
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // ==================== HEADERS ====================

  /// Headers par défaut
  static Map<String, String> _getHeaders({
    bool withAuth = false,
    String? token,
  }) {
    final headers = {'Content-Type': 'application/json'};

    if (withAuth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================== GESTION DES ERREURS ====================

  /// Gérer les erreurs de réponse
  static String _handleError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['error'] ?? 'Une erreur est survenue';
    } catch (e) {
      return 'Erreur de connexion au serveur';
    }
  }

  // ==================== AUTHENTIFICATION ====================

  /// Inscription
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String ageRange,
    String role = 'USER',
    String? professionalTitle,
    String? parentEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'age_range': ageRange,
          'role': role,
          if (professionalTitle != null)
            'professional_title': professionalTitle,
          if (parentEmail != null && parentEmail.isNotEmpty)
            'parent_email': parentEmail,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Connexion
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Sauvegarder le token et les données utilisateur
        await saveToken(data['token']);
        await saveUser(data['user']);

        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Vérification d'email
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-email/$token'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Renvoyer l'email de vérification
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification'),
        headers: _getHeaders(),
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Demande de réinitialisation de mot de passe
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _getHeaders(),
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Réinitialiser le mot de passe
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/$token'),
        headers: _getHeaders(),
        body: json.encode({'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Obtenir les informations de l'utilisateur connecté
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non connecté'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(withAuth: true, token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveUser(data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  /// Mettre à jour les paramètres utilisateur
  Future<void> updateUserSettings(
    String token,
    Map<String, dynamic> settings,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/settings'),
      headers: _getHeaders(token: token),
      body: jsonEncode(settings),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour des paramètres');
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    await deleteToken();
  }

  // ==================== PROFIL ====================

  /// Upload avatar
  static Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non connecté'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/me/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'avatar_url': data['avatar_url']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur d\'upload: $e'};
    }
  }

  /// Upload diplôme (pour professionnels)
  static Future<Map<String, dynamic>> uploadDiploma(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Non connecté'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/me/diploma'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('diploma', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'diploma_url': data['diploma_url']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur d\'upload: $e'};
    }
  }

  /// Mettre à jour le profil utilisateur
  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/me'),
        headers: _getHeaders(withAuth: true, token: token),
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mettre à jour les données utilisateur localement
        await saveUser(data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': _handleError(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de mise à jour: $e'};
    }
  }

  // ==================== BAROMÈTRE D'HUMEUR ====================

  /// Sauvegarder l'humeur
  Future<void> saveMood({
    required int moodLevel,
    String? note,
    String? userId,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'mood_level': moodLevel,
        'note': note,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la sauvegarde de l\'humeur');
    }
  }

  /// Obtenir l'historique d'humeur
  Future<List<MoodEntry>> getMoodHistory({
    required String userId,
    int limit = 30,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/history?user_id=$userId&limit=$limit'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['moods'];
      return data.map((json) => MoodEntry.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération de l\'historique');
    }
  }

  /// Obtenir les statistiques d'humeur
  Future<Map<String, dynamic>> getMoodStats({
    required String userId,
    int days = 7,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/stats?user_id=$userId&days=$days'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques');
    }
  }

  /// Obtenir l'humeur du jour
  Future<Map<String, dynamic>> getTodayMood({
    required String userId,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/today?user_id=$userId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération de l\'humeur du jour');
    }
  }

  // ==================== QUIZ ====================

  /// Obtenir tous les quiz
  Future<Map<String, dynamic>> getQuizzes({String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quizzes'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des quiz');
    }
  }

  /// Obtenir un quiz spécifique
  Future<Map<String, dynamic>> getQuiz(String quizId, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quizzes/$quizId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du quiz');
    }
  }

  /// Soumettre un quiz
  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required Map<int, int> answers,
    String? userId,
    String? token,
  }) async {
    // Convertir Map<int, int> en Map<String, dynamic> pour JSON
    final answersJson = answers.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final response = await http.post(
      Uri.parse('$baseUrl/quizzes/$quizId/submit'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'answers': answersJson, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la soumission du quiz');
    }
  }

  /// Obtenir l'historique des quiz d'un utilisateur
  Future<List<Map<String, dynamic>>> getQuizHistory({
    required String userId,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quizzes/results?user_id=$userId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception(
        'Erreur lors de la récupération de l\'historique des quiz',
      );
    }
  }

  // ==================== CONTENUS ====================

  /// Obtenir les contenus recommandés selon l'humeur
  Future<Map<String, dynamic>> getRecommendedContent({
    required int mood,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/recommended?mood=$mood'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des recommandations');
    }
  }

  /// Obtenir tous les articles
  Future<Map<String, dynamic>> getArticles({String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/articles'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des articles');
    }
  }

  /// Obtenir un article spécifique
  Future<Map<String, dynamic>> getArticle(
    String articleId, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/articles/$articleId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération de l\'article');
    }
  }

  /// Obtenir tous les scénarios
  Future<Map<String, dynamic>> getScenarios({String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/scenarios'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des scénarios');
    }
  }

  /// Obtenir un scénario spécifique
  Future<Map<String, dynamic>> getScenario(
    String scenarioId, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/scenarios/$scenarioId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du scénario');
    }
  }

  /// Obtenir un quiz spécifique
  Future<Map<String, dynamic>> getQuizById(
    String quizId, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quizzes/$quizId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du quiz');
    }
  }

  // ==================== CHAT IA ====================

  /// Envoyer un message au chat
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    required String userId,
    int? moodContext,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/message'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'message': message,
        'user_id': userId,
        'mood_context': moodContext,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'envoi du message');
    }
  }

  /// Obtenir l'historique du chat
  Future<Map<String, dynamic>> getChatHistory({
    required String userId,
    int limit = 50,
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history?user_id=$userId&limit=$limit'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération de l\'historique');
    }
  }

  /// Effacer l'historique du chat
  Future<void> clearChatHistory({required String userId, String? token}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/chat/history'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l\'historique');
    }
  }

  /// Obtenir des suggestions de conversation
  Future<List<String>> getChatSuggestions({int? mood, String? token}) async {
    final queryParam = mood != null ? '?mood=$mood' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/chat/suggestions$queryParam'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> suggestions = jsonDecode(
        response.body,
      )['suggestions'];
      return suggestions.cast<String>();
    } else {
      throw Exception('Erreur lors de la récupération des suggestions');
    }
  }

  // ==================== RESSOURCES D'URGENCE ====================

  /// Obtenir les ressources d'urgence
  Future<Map<String, dynamic>> getEmergencyResources() async {
    final response = await http.get(
      Uri.parse('$baseUrl/emergency/resources'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des ressources');
    }
  }

  // ==================== NOTIFICATIONS PUSH (FCM) ====================

  /// Enregistrer un token FCM pour les notifications push
  static Future<Map<String, dynamic>> registerFCMToken({
    required String fcmToken,
    String? deviceType,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'Non authentifié'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/notifications/fcm-token'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'fcm_token': fcmToken,
        'device_type': deviceType,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'enregistrement du token FCM');
    }
  }

  /// Désactiver un token FCM (logout)
  static Future<void> unregisterFCMToken({required String fcmToken}) async {
    final token = await getToken();
    if (token == null) return;

    await http.delete(
      Uri.parse('$baseUrl/notifications/fcm-token'),
      headers: _getHeaders(token: token),
      body: jsonEncode({'fcm_token': fcmToken}),
    );
  }
}
