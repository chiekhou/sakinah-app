import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah_app/services/api_service.dart';

class ParentApiService {
  static String get baseUrl => ApiService.baseUrl;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Vérifier le token de consentement et récupérer les infos de l'enfant
  /// GET /api/auth/confirm-parental-consent/:token
  static Future<Map<String, dynamic>> getConsentInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/confirm-parental-consent/$token'),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Lien invalide'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Confirmer le consentement et créer le compte parent
  /// POST /api/auth/confirm-parental-consent/:token
  static Future<Map<String, dynamic>> confirmConsent(
      String token, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/confirm-parental-consent/$token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        // Sauvegarder le token parent
        if (data['token'] != null) {
          await ApiService.saveToken(data['token']);
          await ApiService.saveUser(data['parent']);
        }
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Récupérer les profils de tous les enfants
  /// GET /api/parent/child
  static Future<Map<String, dynamic>> getChildProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/child'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Récupérer les activités d'un enfant spécifique
  /// GET /api/parent/child/activities?child_id=xxx
  static Future<Map<String, dynamic>> getChildActivities(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/child/activities?child_id=$childId'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Récupérer le journal de supervision d'un enfant
  /// GET /api/parent/child/supervision-logs?child_id=xxx
  static Future<Map<String, dynamic>> getSupervisionLogs(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/child/supervision-logs?child_id=$childId'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Supprimer le compte d'un enfant
  /// DELETE /api/parent/child
  static Future<Map<String, dynamic>> deleteChildAccount(String childId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/parent/child'),
        headers: await _authHeaders(),
        body: json.encode({'child_id': childId}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Révoquer le consentement d'un enfant
  /// POST /api/parent/revoke
  static Future<Map<String, dynamic>> revokeConsent(
      {required String childId, String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/revoke'),
        headers: await _authHeaders(),
        body: json.encode({
          'child_id': childId,
          'reason': reason ?? 'Révocation par le parent',
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Créer un compte enfant depuis le dashboard parent
  /// POST /api/parent/add-child
  static Future<Map<String, dynamic>> addChild({
    required String username,
    required String email,
    required String password,
    required String ageRange,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/add-child'),
        headers: await _authHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'age_range': ageRange,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Activer / désactiver les publications communautaires d'un enfant
  /// PATCH /api/parent/child/permissions
  static Future<Map<String, dynamic>> toggleChildPosting({
    required String childId,
    required bool canPost,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/parent/child/permissions'),
        headers: await _authHeaders(),
        body: json.encode({'child_id': childId, 'can_post_content': canPost}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Récupérer les modifications de profil en attente d'approbation
  /// GET /api/parent/child/pending-updates?child_id=xxx
  static Future<Map<String, dynamic>> getPendingUpdates(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/child/pending-updates?child_id=$childId'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Approuver une modification de profil
  /// POST /api/parent/child/approve-update
  static Future<Map<String, dynamic>> approveUpdate(String updateId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/child/approve-update'),
        headers: await _authHeaders(),
        body: json.encode({'update_id': updateId}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Rejeter une modification de profil
  /// POST /api/parent/child/reject-update
  static Future<Map<String, dynamic>> rejectUpdate(String updateId,
      {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/child/reject-update'),
        headers: await _authHeaders(),
        body: json.encode({
          'update_id': updateId,
          if (reason != null) 'reason': reason,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) return {'success': true, ...data};
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }

  /// Envoyer une demande de suppression de compte
  /// POST /api/parent/delete-request
  static Future<Map<String, dynamic>> sendDeleteRequest() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/delete-request'),
        headers: await _authHeaders(),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'error': data['error'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }
}
