import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserService {
  static const String _userIdKey = 'user_id';
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _userId;
  final _uuid = const Uuid();

  /// Récupérer ou créer l'UUID de l'utilisateur
  Future<String> getUserId() async {
    // Si déjà en mémoire, retourner directement
    if (_userId != null) {
      return _userId!;
    }

    // Sinon, charger depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey);

    // Si pas encore d'UUID, en créer un nouveau
    if (_userId == null) {
      _userId = _uuid.v4();
      await prefs.setString(_userIdKey, _userId!);
      debugPrint('🆔 Nouvel UUID créé: $_userId');
    } else {
      debugPrint('🆔 UUID chargé: $_userId');
    }

    return _userId!;
  }

  /// Vérifier si l'utilisateur a déjà un UUID
  Future<bool> hasUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userIdKey);
  }

  /// Réinitialiser l'UUID (pour les tests ou déconnexion)
  Future<void> resetUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    _userId = null;
    debugPrint('🗑️ UUID supprimé');
  }

  /// Définir manuellement un UUID (pour migration ou connexion)
  Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    _userId = userId;
    debugPrint('🆔 UUID défini: $userId');
  }
}
