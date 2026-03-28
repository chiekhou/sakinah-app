import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour suivre la progression de l'utilisateur (local, sans backend)
/// Stocke les IDs des quiz complétés, articles lus et scénarios terminés
class ProgressService {
  static const _keyQuizzes = 'completed_quizzes';
  static const _keyArticles = 'read_articles';
  static const _keyScenarios = 'completed_scenarios';

  // ─── Quiz ────────────────────────────────────────────────────────────────

  static Future<void> markQuizCompleted(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getCompletedQuizIds();
    ids.add(quizId);
    await prefs.setString(_keyQuizzes, jsonEncode(ids.toList()));
  }

  static Future<Set<String>> getCompletedQuizIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyQuizzes);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  static Future<bool> isQuizCompleted(String quizId) async {
    final ids = await getCompletedQuizIds();
    return ids.contains(quizId);
  }

  // ─── Article ─────────────────────────────────────────────────────────────

  static Future<void> markArticleRead(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getReadArticleIds();
    ids.add(articleId);
    await prefs.setString(_keyArticles, jsonEncode(ids.toList()));
  }

  static Future<Set<String>> getReadArticleIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyArticles);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  static Future<bool> isArticleRead(String articleId) async {
    final ids = await getReadArticleIds();
    return ids.contains(articleId);
  }

  // ─── Scénario ────────────────────────────────────────────────────────────

  static Future<void> markScenarioCompleted(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getCompletedScenarioIds();
    ids.add(scenarioId);
    await prefs.setString(_keyScenarios, jsonEncode(ids.toList()));
  }

  static Future<Set<String>> getCompletedScenarioIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyScenarios);
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw) as List);
  }

  static Future<bool> isScenarioCompleted(String scenarioId) async {
    final ids = await getCompletedScenarioIds();
    return ids.contains(scenarioId);
  }
}
