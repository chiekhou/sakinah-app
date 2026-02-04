import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/providers/mood_provider.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/services/user_service.dart';
import 'package:sakinah_app/widgets/custom_wigdet.dart';

/// Écran d'historique
/// Affiche l'historique des humeurs, quiz complétés, et scénarios complétés
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MoodEntry> _moodHistory = [];
  List<Map<String, dynamic>> _quizHistory = [];
  bool _isLoading = true;
  bool _isLoadingQuiz = false;
  String? _error;
  String? _errorQuiz;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadMoodHistory();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 &&
        _quizHistory.isEmpty &&
        !_isLoadingQuiz &&
        _errorQuiz == null) {
      _loadQuizHistory();
    }
  }

  Future<void> _loadMoodHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await UserService().getUserId();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final history = await ApiService().getMoodHistory(
        userId: userId,
        limit: 30,
        token: token,
      );

      if (mounted) {
        setState(() {
          _moodHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadQuizHistory() async {
    setState(() {
      _isLoadingQuiz = true;
      _errorQuiz = null;
    });

    try {
      final userId = await UserService().getUserId();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final history = await ApiService().getQuizHistory(
        userId: userId,
        token: token,
      );

      if (mounted) {
        setState(() {
          _quizHistory = history;
          _isLoadingQuiz = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorQuiz = e.toString();
          _isLoadingQuiz = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon historique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Humeurs'),
            Tab(text: 'Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMoodHistory(), _buildQuizHistory()],
      ),
    );
  }

  Widget _buildMoodHistory() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                text: 'Réessayer',
                icon: Icons.refresh,
                onPressed: _loadMoodHistory,
              ),
            ],
          ),
        ),
      );
    }

    if (_moodHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.mood,
                  size: 50,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aucune humeur enregistrée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Utilise le baromètre d\'humeur pour commencer à suivre ton bien-être',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMoodHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _moodHistory.length,
        itemBuilder: (context, index) {
          final entry = _moodHistory[index];
          return _buildMoodCard(entry);
        },
      ),
    );
  }

  Widget _buildMoodCard(MoodEntry entry) {
    final moodData = _getMoodData(entry.moodLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Row(
          children: [
            // Emoji et couleur
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: moodData['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  moodData['emoji'],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodData['label'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(entry.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.note!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHistory() {
    if (_isLoadingQuiz) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorQuiz != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorQuiz!,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                text: 'Réessayer',
                icon: Icons.refresh,
                onPressed: _loadQuizHistory,
              ),
            ],
          ),
        ),
      );
    }

    if (_quizHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.quiz,
                  size: 50,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aucun quiz complété',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Teste tes connaissances en complétant des quiz !',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _quizHistory.length,
        itemBuilder: (context, index) {
          final quiz = _quizHistory[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final score = quiz['score'] as int;
    final completedAt = DateTime.parse(quiz['completed_at'] as String);

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = AppTheme.success;
      scoreLabel = 'Excellent';
    } else if (score >= 60) {
      scoreColor = AppTheme.primary;
      scoreLabel = 'Bien';
    } else if (score >= 40) {
      scoreColor = AppTheme.warning;
      scoreLabel = 'Passable';
    } else {
      scoreColor = AppTheme.error;
      scoreLabel = 'À améliorer';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Row(
          children: [
            // Score
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    scoreLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz['quiz_title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(completedAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Icône
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Aujourd'hui
    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    // Hier
    if (difference.inDays == 1) {
      return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    // Cette semaine
    if (difference.inDays < 7) {
      final weekdays = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];
      final weekday = weekdays[date.weekday - 1];
      return '$weekday à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    // Date complète
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getMoodData(int level) {
    switch (level) {
      case 1:
        return {'emoji': '😢', 'label': 'Très mal', 'color': AppTheme.moodSad};
      case 2:
        return {'emoji': '😕', 'label': 'Mal', 'color': AppTheme.moodAnxious};
      case 3:
        return {
          'emoji': '😐',
          'label': 'Pas terrible',
          'color': AppTheme.warning,
        };
      case 4:
        return {'emoji': '🙂', 'label': 'Correct', 'color': AppTheme.moodCalm};
      case 5:
        return {'emoji': '😊', 'label': 'Bien', 'color': AppTheme.success};
      case 6:
        return {'emoji': '😄', 'label': 'Très bien', 'color': AppTheme.success};
      case 7:
        return {'emoji': '😁', 'label': 'Excellent', 'color': AppTheme.success};
      default:
        return {
          'emoji': '😐',
          'label': 'Inconnu',
          'color': AppTheme.textSecondary,
        };
    }
  }
}
