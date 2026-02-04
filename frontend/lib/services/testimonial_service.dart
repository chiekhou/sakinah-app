import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sakinah_app/config/api_config.dart';

class TestimonialService {
  /// Créer un témoignage
  static Future<Map<String, dynamic>> createTestimonial({
    required String token,
    required String content,
    int? moodLevel,
    bool isAnonymous = true,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/testimonials'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
        'mood_level': moodLevel,
        'is_anonymous': isAnonymous,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ??
            'Erreur lors de la création du témoignage',
      );
    }
  }

  /// Récupérer tous les témoignages approuvés
  static Future<List<dynamic>> getAllTestimonials({
    String? token,
    int limit = 50,
    int offset = 0,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/testimonials?limit=$limit&offset=$offset',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['testimonials'] ?? [];
    } else {
      throw Exception('Erreur lors de la récupération des témoignages');
    }
  }

  /// Récupérer un témoignage par ID
  static Future<Map<String, dynamic>> getTestimonialById({
    required String id,
    String? token,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/testimonials/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Témoignage non trouvé');
    }
  }

  /// Récupérer mes témoignages
  static Future<List<dynamic>> getMyTestimonials({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/testimonials/my'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['testimonials'] ?? [];
    } else {
      throw Exception('Erreur lors de la récupération de vos témoignages');
    }
  }

  /// Liker/Unlike un témoignage
  static Future<Map<String, dynamic>> toggleLike({
    required String token,
    required String testimonialId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/testimonials/$testimonialId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du like');
    }
  }

  /// Commenter un témoignage
  static Future<Map<String, dynamic>> addComment({
    required String token,
    required String testimonialId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/testimonials/$testimonialId/comment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ??
            'Erreur lors de l\'ajout du commentaire',
      );
    }
  }
}
