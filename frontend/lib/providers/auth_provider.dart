import 'package:flutter/material.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/services/user_service.dart';
import 'package:sakinah_app/services/push_notification_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Initialisation - Vérifier si un token existe
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _token = await ApiService.getToken();

      if (_token != null) {
        // Vérifier que le token est toujours valide
        try {
          final result = await ApiService.getMe();
          if (result['success']) {
            _currentUser = result['user'];
            _isAuthenticated = true;
          } else {
            // Token invalide ou expiré
            await logout();
          }
        } catch (e) {
          // Token invalide ou expiré
          await logout();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String ageRange,
    String role = 'USER',
    String? professionalTitle,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        ageRange: ageRange,
        role: role,
        professionalTitle: professionalTitle,
      );

      _isLoading = false;
      notifyListeners();

      // Note: On ne sauvegarde pas le token ici car l'utilisateur
      // doit d'abord vérifier son email
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.login(email: email, password: password);

      if (result['success']) {
        _token = result['token'];
        _currentUser = result['user'];
        _isAuthenticated = true;

        // Enregistrer le token FCM après connexion
        await PushNotificationService.registerTokenAfterLogin();
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    // Désinscrire le token FCM avant la déconnexion
    await PushNotificationService.unregisterToken();

    _token = null;
    _currentUser = null;
    _isAuthenticated = false;

    await ApiService.logout();

    // Vider le cache UserService pour qu'il réinitialise l'ID au prochain appel
    UserService().clearCache();

    notifyListeners();
  }

  /// Rafraîchir les données de l'utilisateur
  Future<void> refreshUser() async {
    try {
      final result = await ApiService.getMe();
      if (result['success']) {
        _currentUser = result['user'];
        notifyListeners();
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  /// Vérifier si l'utilisateur est un professionnel
  bool get isProfessional {
    if (_currentUser == null) return false;
    final role = _currentUser!['role'] as String?;
    return ['EDUCATEUR', 'PSYCHOLOGUE', 'INTERVENANT'].contains(role);
  }

  /// Vérifier si le professionnel doit uploader son diplôme
  bool get needsDiplomaUpload {
    return _currentUser?['needs_diploma_upload'] == true;
  }

  /// Vérifier si le professionnel est en attente d'approbation
  bool get awaitingAdminApproval {
    return _currentUser?['awaiting_admin_approval'] == true;
  }

  /// Vérifier si le professionnel est vérifié
  bool get isVerified {
    return _currentUser?['is_verified'] == true;
  }

  /// Vérifier si l'utilisateur est mineur
  bool get isMinor {
    return _currentUser?['is_minor'] == true;
  }

  /// Vérifier si le mineur est autorisé à publier du contenu communautaire
  /// (toujours true pour les non-mineurs)
  bool get canPostContent {
    return _currentUser?['can_post_content'] != false;
  }
}
