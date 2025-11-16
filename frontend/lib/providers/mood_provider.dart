import 'package:flutter/material.dart';
import 'package:sakinah_app/services/api_service.dart';

class MoodProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  int? currentMood;
  String? currentNote;
  List<MoodEntry> moodHistory = [];
  bool isLoading = false;

  /// Sauvegarder l'humeur du jour
  Future<void> saveMood({required int moodLevel, String? note}) async {
    try {
      isLoading = true;
      notifyListeners();

      currentMood = moodLevel;
      currentNote = note;

      // Appel API
      await _apiService.saveMood(moodLevel: moodLevel, note: note);

      // Rafraîchir l'historique
      await fetchMoodHistory();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Récupérer l'historique des humeurs
  Future<void> fetchMoodHistory() async {
    try {
      isLoading = true;
      notifyListeners();

      final history = await _apiService.getMoodHistory();
      moodHistory = history;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Obtenir la moyenne d'humeur sur les 7 derniers jours
  double get weeklyMoodAverage {
    if (moodHistory.isEmpty) return 0;

    final now = DateTime.now();
    final lastWeek = moodHistory.where((entry) {
      return now.difference(entry.timestamp).inDays <= 7;
    }).toList();

    if (lastWeek.isEmpty) return 0;

    final sum = lastWeek.fold<int>(0, (prev, entry) => prev + entry.moodLevel);
    return sum / lastWeek.length;
  }

  /// Obtenir la tendance (amélioration/détérioration)
  String get moodTrend {
    if (moodHistory.length < 2) return 'stable';

    final recentMoods = moodHistory.take(7).toList();
    final olderMoods = moodHistory.skip(7).take(7).toList();

    if (recentMoods.isEmpty || olderMoods.isEmpty) return 'stable';

    final recentAvg =
        recentMoods.fold<int>(0, (prev, entry) => prev + entry.moodLevel) /
        recentMoods.length;
    final olderAvg =
        olderMoods.fold<int>(0, (prev, entry) => prev + entry.moodLevel) /
        olderMoods.length;

    if (recentAvg > olderAvg + 0.5) return 'amélioration';
    if (recentAvg < olderAvg - 0.5) return 'détérioration';
    return 'stable';
  }
}

class MoodEntry {
  final String id;
  final int moodLevel;
  final String? note;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.moodLevel,
    this.note,
    required this.timestamp,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      moodLevel: json['mood_level'],
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
