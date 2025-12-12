import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah_app/providers/mood_provider.dart';

class ApiService {
  // À remplacer par l'URL de votre backend
  static const String baseUrl = 'http://localhost:3000/api';

  final http.Client _client = http.Client();

  /// Headers communs
  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================== AUTHENTIFICATION ====================

  /// Inscription
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String ageRange,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'age_range': ageRange,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  /// Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

  /// Obtenir l'utilisateur actuel
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération de l\'utilisateur');
    }
  }

  /// Mettre à jour les paramètres utilisateur
  Future<void> updateUserSettings(
    String token,
    Map<String, dynamic> settings,
  ) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/user/settings'),
      headers: _getHeaders(token: token),
      body: jsonEncode(settings),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour des paramètres');
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
    final response = await _client.post(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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

    final response = await _client.post(
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

  // ==================== CONTENUS ====================

  /// Obtenir les contenus recommandés selon l'humeur
  Future<Map<String, dynamic>> getRecommendedContent({
    required int mood,
    String? token,
  }) async {
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.get(
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
    final response = await _client.post(
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
    final response = await _client.get(
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
    final response = await _client.delete(
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
    final response = await _client.get(
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
    final response = await _client.get(
      Uri.parse('$baseUrl/emergency/resources'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des ressources');
    }
  }

  /// Fermer le client HTTP
  void dispose() {
    _client.close();
  }
}
