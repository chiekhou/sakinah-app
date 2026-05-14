import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakinah_app/config/api_config.dart';

class SafetyService {
  static String get _base => ApiConfig.baseUrl;

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Enregistre que le mineur a lu et accepté le rappel de sécurité.
  static Future<void> acknowledge(String token) async {
    final response = await http.post(
      Uri.parse('$_base/safety/acknowledge'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erreur acknowledge');
    }
  }

  /// Retourne le statut de sécurité (rappel accepté, can_post_content, etc.)
  static Future<Map<String, dynamic>> getStatus(String token) async {
    final response = await http.get(
      Uri.parse('$_base/safety/status'),
      headers: _headers(token),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Erreur status');
  }

  /// Notifie le parent qu'un mineur veut modifier ses informations personnelles.
  static Future<void> requestProfileUpdate(String token) async {
    final response = await http.post(
      Uri.parse('$_base/safety/request-profile-update'),
      headers: _headers(token),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Erreur notification parent');
    }
  }
}
