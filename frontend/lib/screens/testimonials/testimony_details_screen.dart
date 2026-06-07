import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/providers/testimonials_provider.dart';
import 'package:sakinah_app/services/testimonial_service.dart';
import 'package:sakinah_app/utils/auth_helper.dart';
import 'package:sakinah_app/services/safety_service.dart';
import 'package:sakinah_app/widgets/safety_reminder_dialog.dart';

class TestimonyDetailScreen extends StatefulWidget {
  final String testimonialId;

  const TestimonyDetailScreen({super.key, required this.testimonialId});

  @override
  State<TestimonyDetailScreen> createState() => _TestimonyDetailScreenState();
}

class _TestimonyDetailScreenState extends State<TestimonyDetailScreen> {
  Map<String, dynamic>? _testimony;
  bool _isLoading = true;
  String? _errorMessage;

  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _showCrisisBanner = false;

  static const _crisisKeywords = [
    'suicide', 'suicidaire', 'suicider', 'me suicider',
    'envie de mourir', 'veux mourir', 'plus envie de vivre', 'mourir',
    'me tuer', 'en finir', "m'en finir", 'mettre fin',
    'automutilation', 'me couper', 'me blesser', 'me faire du mal',
    'violé', 'violée', 'viol', 'maltraitance', 'abus sexuel',
    'disparaître', 'mieux sans moi', 'je suis un fardeau',
  ];

  bool _hasCrisisKeyword(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any((k) => lower.contains(k));
  }

  @override
  void initState() {
    super.initState();
    _loadTestimony();
    _commentController.addListener(() {
      final hasCrisis = _hasCrisisKeyword(_commentController.text);
      if (hasCrisis != _showCrisisBanner) {
        setState(() => _showCrisisBanner = hasCrisis);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTestimony() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final testimony = await TestimonialService.getTestimonialById(
        id: widget.testimonialId,
        token: authProvider.token,
      );

      setState(() {
        _testimony = testimony;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final testimonialsProvider = Provider.of<TestimonialsProvider>(
      context,
      listen: false,
    );

    final canProceed = await AuthHelper.requireAuth(
      context,
      feature: 'liker ce témoignage',
    );

    if (!canProceed) return;

    try {
      // Utilise le provider centralisé → synchronise aussi la liste
      await testimonialsProvider.toggleLike(
        widget.testimonialId,
        authProvider.token!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // Capturer avant le premier await
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMinor = authProvider.isMinor;

    final canProceed = await AuthHelper.requireAuth(
      context,
      feature: 'commenter ce témoignage',
    );
    if (!canProceed || !mounted) return;

    // Vérification contrôle parental
    if (isMinor && !authProvider.canPostContent) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Autorisation requise'),
          content: const Text(
            'Ton parent doit activer les publications depuis '
            'l\'Espace Parent avant que tu puisses commenter.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // Rappel de sécurité pour les mineurs autorisés
    if (isMinor) {
      final accepted = await showSafetyReminderDialog(
        context,
        feature: 'les commentaires',
      );
      if (!accepted || !mounted) return;
      // Enregistrer l'acceptation côté backend
      if (authProvider.token != null) {
        SafetyService.acknowledge(authProvider.token!).catchError((_) {});
      }
    }

    setState(() => _isSubmittingComment = true);

    try {
      await TestimonialService.addComment(
        token: authProvider.token!,
        testimonialId: widget.testimonialId,
        content: _commentController.text.trim(),
      );

      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Commentaire envoyé ! Il sera visible après modération 💚',
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
        _loadTestimony();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Témoignage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTestimony,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_testimony == null) {
      return const Center(child: Text('Témoignage non trouvé'));
    }

    return RefreshIndicator(
      onRefresh: _loadTestimony,
      color: AppTheme.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestimonyCard(),
          const SizedBox(height: 24),
          _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildTestimonyCard() {
    final moodLevel = _testimony!['mood_level'];
    final content = _testimony!['content'] ?? '';
    final author = _testimony!['author'];
    final commentsCount = _testimony!['comments_count'] ?? 0;
    final createdAt = _testimony!['created_at'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author ?? 'Anonyme',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (moodLevel != null) _buildMoodBadge(moodLevel),
              ],
            ),
            const SizedBox(height: 20),
            // Content
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Actions — lit l'état depuis le provider (source de vérité commune)
            Consumer<TestimonialsProvider>(
              builder: (context, provider, _) {
                final inList = provider.containsTestimonial(
                  widget.testimonialId,
                );
                final hasLiked = inList
                    ? provider.getLikeState(widget.testimonialId)
                    : _testimony!['has_liked'] as bool? ?? false;
                final likesCount = inList
                    ? provider.getLikesCount(widget.testimonialId)
                    : _testimony!['likes_count'] as int? ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _toggleLike,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 24,
                                color: hasLiked ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$likesCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: hasLiked
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey[300]),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 24,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$commentsCount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    final comments = _testimony!['comments'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaires (${comments.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (comments.isEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun commentaire pour le moment',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sois le premier à réagir !',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...comments.map((comment) => _buildCommentCard(comment)),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final content = comment['content'] ?? '';
    final author = comment['author'] ?? 'Anonyme';
    final createdAt = comment['created_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showCrisisBanner) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[300]!, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Tu n\'es pas seul(e)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Si tu traverses une période difficile, appelle gratuitement :',
                    style: TextStyle(fontSize: 12, color: Colors.red[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📞 3114  –  Prévention suicide     📞 119  –  Enfance en danger',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Écris un commentaire bienveillant...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: _isSubmittingComment ? null : _submitComment,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: _isSubmittingComment
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBadge(int level) {
    String emoji;
    Color color;

    if (level <= 2) {
      emoji = '😢';
      color = Colors.red;
    } else if (level <= 4) {
      emoji = '😕';
      color = Colors.orange;
    } else if (level <= 5) {
      emoji = '😐';
      color = Colors.amber;
    } else if (level <= 6) {
      emoji = '🙂';
      color = Colors.lightGreen;
    } else {
      emoji = '😄';
      color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return 'Il y a ${diff.inMinutes}min';
        }
        return 'Il y a ${diff.inHours}h';
      } else if (diff.inDays == 1) {
        return 'Hier';
      } else if (diff.inDays < 7) {
        return 'Il y a ${diff.inDays}j';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
