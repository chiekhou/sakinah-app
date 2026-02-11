import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sakinah_app/services/api_service.dart';

class UserService {
  static const String _anonymousIdKey = 'anonymous_user_id';
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _cachedUserId;
  final _uuid = const Uuid();

  /// Récupérer l'ID utilisateur :
  /// - Pour utilisateur connecté : utilise le vrai user.id de la base de données
  /// - Pour utilisateur anonyme : génère/utilise un UUID local
  Future<String> getUserId() async {
    // 1. Vérifier si l'utilisateur est connecté
    final userData = await ApiService.getUser();

    if (userData != null && userData['id'] != null) {
      // Utilisateur connecté → utiliser son vrai ID
      _cachedUserId = userData['id'].toString();
      // PRODUCTION: Log sensible désactivé (expose user ID)
      // debugPrint('🆔 Utilisateur connecté - ID: $_cachedUserId');
      return _cachedUserId!;
    }

    // 2. Utilisateur anonyme → utiliser/créer un UUID local
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }

    // Charger l'UUID anonyme depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString(_anonymousIdKey);

    // Si pas encore d'UUID anonyme, en créer un nouveau
    if (_cachedUserId == null) {
      _cachedUserId = 'anonymous_${_uuid.v4()}';
      await prefs.setString(_anonymousIdKey, _cachedUserId!);
      debugPrint('🆔 Nouvel UUID anonyme créé: $_cachedUserId');
    } else {
      debugPrint('🆔 UUID anonyme chargé: $_cachedUserId');
    }

    return _cachedUserId!;
  }

  /// Vérifier si l'utilisateur a déjà un UUID anonyme
  Future<bool> hasAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_anonymousIdKey);
  }

  /// Réinitialiser le cache (utile après déconnexion)
  void clearCache() {
    _cachedUserId = null;
    debugPrint('🗑️ Cache utilisateur vidé');
  }

  /// Réinitialiser l'UUID anonyme (pour les tests)
  Future<void> resetAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_anonymousIdKey);
    _cachedUserId = null;
    debugPrint('🗑️ UUID anonyme supprimé');
  }
}
