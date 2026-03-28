import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/widgets/content_card.dart';
import 'package:sakinah_app/screens/articles/articles_details_screen.dart';
import 'package:sakinah_app/screens/quiz/quiz_details_screen.dart';
import 'package:sakinah_app/screens/scenarios/scenario_details_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? mood;

  const HomeScreen({super.key, this.mood});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (widget.mood == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _apiService.getRecommendedContent(mood: widget.mood!);

      setState(() {
        _recommendations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.mood == null) {
      return _buildWelcomeView();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_recommendations != null) ...[_buildRecommendationsSection()],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Bienvenue ! 👋',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Commence par enregistrer ton humeur pour recevoir des recommandations personnalisées.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.mood, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Enregistre ton humeur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chaque jour compte pour ton bien-être',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigation vers baromètre
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Commencer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final message = _recommendations?['message'] ?? '';
    final moodLevel = _recommendations?['mood_level'] ?? 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
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
                child: Text(
                  AppTheme.getMoodEmoji(moodLevel),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ton humeur du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTheme.getMoodLabel(moodLevel),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recs = _recommendations!['recommendations'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recs['articles'] != null &&
            (recs['articles'] as List).isNotEmpty) ...[
          _buildSectionTitle('📰 Articles pour toi'),
          const SizedBox(height: 12),
          _buildArticlesList(recs['articles'] as List),
          const SizedBox(height: 24),
        ],
        if (recs['quizzes'] != null &&
            (recs['quizzes'] as List).isNotEmpty) ...[
          _buildSectionTitle('🧠 Quiz recommandés'),
          const SizedBox(height: 12),
          _buildQuizzesList(recs['quizzes'] as List),
          const SizedBox(height: 24),
        ],
        if (recs['scenarios'] != null &&
            (recs['scenarios'] as List).isNotEmpty) ...[
          _buildSectionTitle('🎭 Mises en situation'),
          const SizedBox(height: 12),
          _buildScenariosList(recs['scenarios'] as List),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildArticlesList(List articles) {
    return Column(
      children: articles.map((article) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 180,
            child: ContentCard(
              title: article['title'],
              subtitle: '${article['reading_time_minutes']} min',
              type: article['title'],
              theme: article['theme'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      articleId: article['_id'] ?? article['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuizzesList(List quizzes) {
    return Column(
      children: quizzes.map((quiz) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 180,
            child: ContentCard(
              title: quiz['title'],
              subtitle: '${quiz['duration_minutes']} min',
              type: quiz['title'],
              theme: quiz['theme'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizDetailScreen(quizId: quiz['_id'] ?? quiz['id']),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScenariosList(List scenarios) {
    return Column(
      children: scenarios.map((scenario) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 180,
            child: ContentCard(
              title: scenario['title'],
              subtitle: '${scenario['duration_minutes']} min',
              type: scenario['title'],
              theme: scenario['theme'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScenarioDetailScreen(
                      scenarioId: scenario['_id'] ?? scenario['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
