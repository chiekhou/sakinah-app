import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/providers/testimonials_provider.dart';
import 'package:sakinah_app/screens/testimonials/create_testimonal_screen.dart';
import 'package:sakinah_app/screens/testimonials/testimony_details_screen.dart';
import 'package:sakinah_app/utils/auth_helper.dart';
import 'package:sakinah_app/widgets/safety_reminder_dialog.dart';

class TestimonialsScreen extends StatefulWidget {
  const TestimonialsScreen({super.key});

  @override
  State<TestimonialsScreen> createState() => _TestimonialsScreenState();
}

class _TestimonialsScreenState extends State<TestimonialsScreen> {
  @override
  void initState() {
    super.initState();
    // Chargement initial via le provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TestimonialsProvider>(context, listen: false)
          .loadTestimonials(authProvider.token);
    });
  }

  Future<void> _reload() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<TestimonialsProvider>(context, listen: false)
        .loadTestimonials(authProvider.token);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isConnected = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: isConnected
            ? IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.white),
                tooltip: 'Mes témoignages',
                onPressed: () {
                  Navigator.pushNamed(context, '/my-testimonials');
                },
              )
            : null,
        title: const Text(
          'Témoignages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        color: AppTheme.primaryColor,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Capturer tout ce qui dépend du context AVANT le premier await
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final isMinor = authProvider.isMinor;
          final navigator = Navigator.of(context);

          final canProceed = await AuthHelper.requireAuth(
            context,
            feature: 'partager ton témoignage',
          );
          if (!canProceed || !mounted) return;

          // Vérification contrôle parental pour les mineurs
          if (isMinor && !authProvider.canPostContent) {
            showDialog(
              context: navigator.context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text('Autorisation requise'),
                content: const Text(
                  'Ton parent doit activer les publications depuis '
                  'l\'Espace Parent avant que tu puisses partager du contenu.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(navigator.context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor),
                    child: const Text('OK',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
            return;
          }

          // Dialog sécurité obligatoire pour les mineurs autorisés
          if (isMinor) {
            final accepted = await showSafetyReminderDialog(
              navigator.context,
              feature: 'la section Témoignages',
            );
            if (!accepted || !mounted) return;
          }

          final result = await navigator.push(
            MaterialPageRoute(
              builder: (_) => const CreateTestimonyScreen(),
            ),
          );

          if (result == true) {
            _reload();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Partager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TestimonialsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        if (provider.error != null) {
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
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _reload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.testimonials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucun témoignage pour le moment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sois le premier à partager ton expérience !',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100,
          ),
          itemCount: provider.testimonials.length,
          itemBuilder: (context, index) {
            final testimony = provider.testimonials[index];
            return _TestimonyCard(
              testimony: testimony,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestimonyDetailScreen(
                      testimonialId: testimony['id'].toString(),
                    ),
                  ),
                );
                // Pas besoin de recharger — le provider est déjà synchronisé
              },
              onLikeToggle: () async {
                // Capturer tout avant le premier await
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final testimonialsProvider = Provider.of<TestimonialsProvider>(
                  context,
                  listen: false,
                );
                final messenger = ScaffoldMessenger.of(context);

                final canProceed = await AuthHelper.requireAuth(
                  context,
                  feature: 'liker ce témoignage',
                );
                if (!canProceed) return;

                try {
                  await testimonialsProvider.toggleLike(
                    testimony['id'].toString(),
                    authProvider.token!,
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _TestimonyCard extends StatelessWidget {
  final Map<String, dynamic> testimony;
  final VoidCallback onTap;
  final VoidCallback onLikeToggle;

  const _TestimonyCard({
    required this.testimony,
    required this.onTap,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final moodLevel = testimony['mood_level'];
    final content = testimony['content'] ?? '';
    final author = testimony['author'];
    final likesCount = testimony['likes_count'] ?? 0;
    final commentsCount = testimony['comments_count'] ?? 0;
    final hasLiked = testimony['has_liked'] ?? false;
    final createdAt = testimony['created_at'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 24,
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
                            fontSize: 16,
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
                  if (moodLevel != null) _buildMoodBadge(moodLevel),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  _buildActionButton(
                    icon: hasLiked ? Icons.favorite : Icons.favorite_border,
                    label: likesCount.toString(),
                    color: hasLiked ? Colors.red : Colors.grey[600]!,
                    onTap: onLikeToggle,
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: commentsCount.toString(),
                    color: Colors.grey[600]!,
                    onTap: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
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
