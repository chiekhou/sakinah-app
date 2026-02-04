import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AdminModerationService {
  /// Récupérer les témoignages en attente
  static Future<List<dynamic>> getPendingTestimonials({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/testimonials/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['testimonials'] ?? [];
    } else {
      throw Exception('Erreur lors de la récupération des témoignages');
    }
  }

  /// Modérer un témoignage
  static Future<Map<String, dynamic>> moderateTestimonial({
    required String token,
    required String testimonialId,
    required String status,
    String? moderationNote,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/admin/testimonials/$testimonialId/moderate',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        if (moderationNote != null) 'moderation_note': moderationNote,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Erreur lors de la modération',
      );
    }
  }

  /// Récupérer les commentaires en attente
  static Future<List<dynamic>> getPendingComments({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/comments/pending'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['comments'] ?? [];
    } else {
      throw Exception('Erreur lors de la récupération des commentaires');
    }
  }

  /// Modérer un commentaire
  static Future<Map<String, dynamic>> moderateComment({
    required String token,
    required String commentId,
    required String status,
    String? moderationNote,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/admin/comments/$commentId/moderate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        if (moderationNote != null) 'moderation_note': moderationNote,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Erreur lors de la modération',
      );
    }
  }

  /// Statistiques de modération
  static Future<Map<String, dynamic>> getModerationStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/moderation/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques');
    }
  }
}
