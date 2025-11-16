import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakinah_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _token;
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Initialisation - Vérifier si un token existe
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      if (_token != null) {
        // Vérifier que le token est toujours valide
        try {
          _currentUser = (await _apiService.getCurrentUser(_token!)) as User?;
          _isAuthenticated = true;
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
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String ageRange,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
        ageRange: ageRange,
      );

      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      _isAuthenticated = true;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Connexion
  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.login(
        email: email,
        password: password,
      );

      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      _isAuthenticated = true;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }

  /// Mettre à jour les paramètres d'accessibilité
  Future<void> updateAccessibilitySettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      if (_currentUser == null) return;

      _currentUser = _currentUser!.copyWith(accessibilitySettings: settings);

      await _apiService.updateUserSettings(_token!, settings);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String ageRange;
  final Map<String, dynamic> accessibilitySettings;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.ageRange,
    required this.accessibilitySettings,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      ageRange: json['age_range'],
      accessibilitySettings: Map<String, dynamic>.from(
        json['accessibility_settings'] ?? {},
      ),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? ageRange,
    Map<String, dynamic>? accessibilitySettings,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      ageRange: ageRange ?? this.ageRange,
      accessibilitySettings:
          accessibilitySettings ?? this.accessibilitySettings,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
