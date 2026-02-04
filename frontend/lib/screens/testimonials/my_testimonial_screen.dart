import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/services/testimonial_service.dart';

class MyTestimonialsScreen extends StatefulWidget {
  const MyTestimonialsScreen({super.key});

  @override
  State<MyTestimonialsScreen> createState() => _MyTestimonialsScreenState();
}

class _MyTestimonialsScreenState extends State<MyTestimonialsScreen> {
  List<dynamic> _testimonials = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyTestimonials();
  }

  Future<void> _loadMyTestimonials() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final testimonials = await TestimonialService.getMyTestimonials(
        token: authProvider.token!,
      );

      setState(() {
        _testimonials = testimonials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mes témoignages',
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
      body: RefreshIndicator(
        onRefresh: _loadMyTestimonials,
        color: AppTheme.primaryColor,
        child: _buildBody(),
      ),
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
              onPressed: _loadMyTestimonials,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_testimonials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Aucun témoignage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu n\'as pas encore partagé de témoignage',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Grouper par statut
    final pending = _testimonials
        .where((t) => t['status'] == 'PENDING')
        .toList();
    final approved = _testimonials
        .where((t) => t['status'] == 'APPROVED')
        .toList();
    final rejected = _testimonials
        .where((t) => t['status'] == 'REJECTED')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistiques
        _buildStatsCard(pending.length, approved.length, rejected.length),
        const SizedBox(height: 24),

        // En attente
        if (pending.isNotEmpty) ...[
          _buildSectionHeader(
            'En attente de modération',
            pending.length,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          ...pending.map((t) => _buildTestimonyCard(t, 'PENDING')),
          const SizedBox(height: 24),
        ],

        // Approuvés
        if (approved.isNotEmpty) ...[
          _buildSectionHeader(
            'Publiés',
            approved.length,
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          ...approved.map((t) => _buildTestimonyCard(t, 'APPROVED')),
          const SizedBox(height: 24),
        ],

        // Rejetés
        if (rejected.isNotEmpty) ...[
          _buildSectionHeader('Non publiés', rejected.length, Colors.red),
          const SizedBox(height: 12),
          ...rejected.map((t) => _buildTestimonyCard(t, 'REJECTED')),
        ],
      ],
    );
  }

  Widget _buildStatsCard(int pending, int approved, int rejected) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('En attente', pending, Colors.orange),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildStatItem('Publiés', approved, AppTheme.primaryColor),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildStatItem('Rejetés', rejected, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonyCard(Map<String, dynamic> testimony, String status) {
    final content = testimony['content'] ?? '';
    final moodLevel = testimony['mood_level'];
    final likesCount = testimony['likes_count'] ?? 0;
    final commentsCount = testimony['comments_count'] ?? 0;
    final createdAt = testimony['created_at'];
    final moderationNote = testimony['moderation_note'];

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusLabel = 'En attente';
        break;
      case 'APPROVED':
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.check_circle;
        statusLabel = 'Publié';
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusLabel = 'Rejeté';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusLabel = 'Inconnu';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (moodLevel != null) _buildMoodBadge(moodLevel),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            // Moderation note si rejeté
            if (status == 'REJECTED' && moderationNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Raison du rejet :',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moderationNote,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Icon(Icons.favorite_border, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$likesCount',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '$commentsCount',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const Spacer(),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBadge(int level) {
    String emoji;
    if (level <= 2) {
      emoji = '😢';
    } else if (level <= 4)
      emoji = '😕';
    else if (level <= 5)
      emoji = '😐';
    else if (level <= 6)
      emoji = '🙂';
    else
      emoji = '😄';

    return Text(emoji, style: const TextStyle(fontSize: 24));
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
