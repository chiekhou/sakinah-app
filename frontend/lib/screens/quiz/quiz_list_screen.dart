import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/models/quiz_model.dart';
import 'package:sakinah_app/screens/quiz/quiz_details_screen.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/services/progress_service.dart';

class QuizListScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const QuizListScreen({super.key, this.onBackPressed});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final ApiService _apiService = ApiService();
  List<Quiz> _quizzes = [];
  List<Quiz> _filteredQuizzes = [];
  bool _isLoading = true;
  String? _selectedTheme;
  List<String> _themes = [];
  Set<String> _completedQuizIds = {};

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getQuizzes(),
        ProgressService.getCompletedQuizIds(),
      ]);

      final data = results[0] as Map<String, dynamic>;
      final completedIds = results[1] as Set<String>;

      final quizzes = (data['quizzes'] as List)
          .map((json) => Quiz.fromJson(json))
          .toList();

      final themes = quizzes.map((q) => q.theme).toSet().toList();
      themes.sort();

      setState(() {
        _quizzes = quizzes;
        _filteredQuizzes = quizzes;
        _themes = themes;
        _completedQuizIds = completedIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _filterByTheme(String? theme) {
    setState(() {
      _selectedTheme = theme;
      if (theme == null) {
        _filteredQuizzes = _quizzes;
      } else {
        _filteredQuizzes = _quizzes.where((q) => q.theme == theme).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_themes.isNotEmpty) _buildThemeFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildQuizList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Teste tes connaissances',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildThemeChip('Tous', null),
          ..._themes.map(
            (theme) => _buildThemeChip(_getThemeLabel(theme), theme),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String label, String? theme) {
    final isSelected = _selectedTheme == theme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
          softWrap: false,
        ),
        selected: isSelected,
        onSelected: (selected) {
          _filterByTheme(selected ? theme : null);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        showCheckmark: false,
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'stress':
        return 'Stress 😰';
      case 'estime':
        return 'Estime de soi 💪';
      case 'harcelement':
        return 'Harcèlement 🛡️';
      case 'famille':
        return 'Famille 🏠';
      case 'emotions':
        return 'Émotions 💭';
      case 'sommeil':
        return 'Sommeil 😴';
      case 'sante_mentale':
        return 'Santé Mentale 🧠';
      case 'conflit':
        return 'Conflit 🤝';
      default:
        return theme;
    }
  }

  Widget _buildQuizList() {
    if (_filteredQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun quiz trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = _filteredQuizzes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQuizCard(quiz),
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    final isDone = _completedQuizIds.contains(quiz.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailScreen(quizId: quiz.id),
          ),
        );
        // Rafraîchir les IDs après retour (au cas où quiz vient d'être fait)
        final ids = await ProgressService.getCompletedQuizIds();
        if (mounted) setState(() => _completedQuizIds = ids);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FFF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDone
              ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau coloré pleine largeur
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _getThemeGradient(quiz.theme),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      quiz.themeEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                if (isDone)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'Fait',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge(
                        quiz.difficultyEmoji,
                        quiz.difficulty,
                        AppTheme.accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    quiz.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questionCount} questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getThemeGradient(String theme) {
    switch (theme) {
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'estime':
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'harcelement':
        return const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'famille':
        return const LinearGradient(
          colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sante_mentale':
        return const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'conflit':
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'emotions':
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sommeil':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }
}
