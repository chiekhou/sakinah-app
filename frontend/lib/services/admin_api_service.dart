import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah_app/services/api_service.dart';

class AdminApiService {
  static String get baseUrl => ApiService.baseUrl;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Lister les utilisateurs avec filtres et pagination
  /// GET /api/admin/users?page=1&limit=20&role=...&status=...&search=...
  static Future<Map<String, dynamic>> listUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      final params = {
        'page': '$page',
        'limit': '$limit',
        if (role != null && role.isNotEmpty) 'role': role,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final uri = Uri.parse('$baseUrl/admin/users').replace(queryParameters: params);
      final response = await http.get(uri, headers: await _authHeaders());
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Changer le statut d'un utilisateur (ACTIVE / SUSPENDED / REJECTED)
  /// PATCH /api/admin/users/:userId/status
  static Future<Map<String, dynamic>> updateUserStatus({
    required String userId,
    required String status,
    String? reason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$userId/status'),
        headers: await _authHeaders(),
        body: json.encode({'status': status, if (reason != null) 'reason': reason}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Supprimer un utilisateur
  /// DELETE /api/admin/users/:userId
  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Professionnels en attente de vérification
  /// GET /api/admin/professionals/pending
  static Future<Map<String, dynamic>> listPendingProfessionals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/professionals/pending'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Approuver ou rejeter un professionnel
  /// POST /api/admin/professionals/:userId/verify
  static Future<Map<String, dynamic>> verifyProfessional({
    required String userId,
    required String decision, // 'VERIFIED' ou 'REJECTED'
    String? note,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/professionals/$userId/verify'),
        headers: await _authHeaders(),
        body: json.encode({'decision': decision, if (note != null) 'note': note}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Promouvoir un utilisateur en admin
  /// POST /api/admin/users/:userId/promote
  static Future<Map<String, dynamic>> promoteToAdmin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/$userId/promote'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }
}
