import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/models/article_model.dart';
import 'package:sakinah_app/services/api_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ApiService _apiService = ApiService();
  ArticleDetail? _article;
  bool _isLoading = true;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final data = await _apiService.getArticle(widget.articleId);
      setState(() {
        _article = ArticleDetail.fromJson(data);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: const Center(child: Text('Article non trouvé')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildContent(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: _getThemeGradient(_article!.theme),
          ),
          child: Center(
            child: Text(
              _getThemeEmoji(_article!.theme),
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge thème
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getThemeEmoji(_article!.theme),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  _getThemeLabel(_article!.theme),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            _article!.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Meta info
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_article!.readingTimeMinutes} min de lecture',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MarkdownBody(
        data: _article!.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: _fontSize,
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
          h1: TextStyle(
            fontSize: _fontSize + 8,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          h2: TextStyle(
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          h3: TextStyle(
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          listBullet: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton augmenter taille
        FloatingActionButton.small(
          heroTag: 'increase',
          onPressed: () {
            if (_fontSize < 24) {
              setState(() {
                _fontSize += 2;
              });
            }
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),

        // Bouton diminuer taille
        FloatingActionButton.small(
          heroTag: 'decrease',
          onPressed: () {
            if (_fontSize > 12) {
              setState(() {
                _fontSize -= 2;
              });
            }
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.remove, color: AppTheme.primaryColor),
        ),
      ],
    );
  }

  String _getThemeEmoji(String theme) {
    switch (theme) {
      case 'stress':
        return '😰';
      case 'estime':
        return '💪';
      case 'harcelement':
        return '🛡️';
      case 'emotions':
        return '💭';
      case 'famille':
        return '🏠';
      case 'sommeil':
        return '😴';
      case 'conflit':
        return '🤝';
      case 'sante_mentale':
        return '🧠 ';
      default:
        return '📰';
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'stress':
        return 'Stress';
      case 'estime':
        return 'Estime de soi';
      case 'harcelement':
        return 'Harcèlement';
      case 'emotions':
        return 'Émotions';
      case 'sommeil':
        return 'Sommeil';
      case 'conflit':
        return 'Conflit';
      case 'famille':
        return 'Famille';
      case 'sante_mentale':
        return 'Santé Mentale';
      default:
        return theme;
    }
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
          colors: [
            Color.fromARGB(255, 161, 219, 52),
            Color.fromARGB(255, 161, 219, 52),
          ],
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
