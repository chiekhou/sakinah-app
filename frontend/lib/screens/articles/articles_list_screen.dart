import 'package:flutter/material.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/models/article_model.dart';
import 'package:sakinah_app/screens/articles/articles_details_screen.dart';
import 'package:sakinah_app/services/api_service.dart';
import 'package:sakinah_app/services/progress_service.dart';

class ArticleListScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const ArticleListScreen({super.key, this.onBackPressed});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final ApiService _apiService = ApiService();
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  String? _selectedTheme;
  List<String> _themes = [];
  Set<String> _readArticleIds = {};

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getArticles(),
        ProgressService.getReadArticleIds(),
      ]);

      final data = results[0] as Map<String, dynamic>;
      final readIds = results[1] as Set<String>;

      final articles = (data['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();

      final themes = articles.map((a) => a.theme).toSet().toList();
      themes.sort();

      setState(() {
        _articles = articles;
        _filteredArticles = articles;
        _themes = themes;
        _readArticleIds = readIds;
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
        _filteredArticles = _articles;
      } else {
        _filteredArticles = _articles.where((a) => a.theme == theme).toList();
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
                  : _buildArticleList(),
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
                  Icons.article_rounded,
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
                      'Articles',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Apprends et découvre',
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
        physics: AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
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
        label: Text(label, textAlign: TextAlign.center),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildArticleList() {
    if (_filteredArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun article trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Séparer les articles featured
    final featuredArticles = _filteredArticles
        .where((a) => a.isFeatured)
        .toList();
    final regularArticles = _filteredArticles
        .where((a) => !a.isFeatured)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (featuredArticles.isNotEmpty) ...[
            const Text(
              '⭐ À la une',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...featuredArticles.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFeaturedArticleCard(article),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (regularArticles.isNotEmpty) ...[
            const Text(
              'Tous les articles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...regularArticles.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildArticleCard(article),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedArticleCard(Article article) {
    final isRead = _readArticleIds.contains(article.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(articleId: article.id),
          ),
        );
        final ids = await ProgressService.getReadArticleIds();
        if (mounted) setState(() => _readArticleIds = ids);
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: _getThemeGradient(article.theme),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Badge "Lu"
            if (isRead)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 12),
                      SizedBox(width: 3),
                      Text('Lu', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

            // Badge featured
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: AppTheme.accentColor),
                    SizedBox(width: 4),
                    Text(
                      'À la une',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenu
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.themeEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readingTimeMinutes} min de lecture',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final isRead = _readArticleIds.contains(article.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(articleId: article.id),
          ),
        );
        final ids = await ProgressService.getReadArticleIds();
        if (mounted) setState(() => _readArticleIds = ids);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFFF0FFF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône thème
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: _getThemeGradient(article.theme),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      article.themeEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                if (isRead)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 10),
                          SizedBox(width: 2),
                          Text('Lu', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.summary,
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
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readingTimeMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
