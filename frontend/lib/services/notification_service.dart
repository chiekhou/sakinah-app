import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class NotificationService {
  /// Récupérer mes notifications
  static Future<Map<String, dynamic>> getMyNotifications({
    required String token,
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/notifications?limit=$limit&offset=$offset&unread_only=$unreadOnly',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des notifications');
    }
  }

  /// Compter les notifications non lues
  static Future<int> getUnreadCount({required String token}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unread_count'] ?? 0;
    } else {
      return 0;
    }
  }

  /// Marquer une notification comme lue
  static Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du marquage de la notification');
    }
  }

  /// Marquer toutes les notifications comme lues
  static Future<void> markAllAsRead({required String token}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du marquage des notifications');
    }
  }

  /// Supprimer une notification
  static Future<void> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la notification');
    }
  }
}
