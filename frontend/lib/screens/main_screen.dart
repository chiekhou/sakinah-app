import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/screens/chat/chat_screen.dart';
import 'package:sakinah_app/screens/quiz/quiz_list_screen.dart';
import 'package:sakinah_app/screens/articles/articles_list_screen.dart';
import 'package:sakinah_app/screens/scenarios/scenarios_list_screen.dart';
import 'package:sakinah_app/screens/home/home_screen.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/screens/testimonials/testimonials_screen.dart';
import 'package:sakinah_app/screens/users/profile_screen.dart';
import 'package:sakinah_app/services/notification_service.dart';
import 'package:sakinah_app/widgets/floating.button_admin.dart';
import 'package:sakinah_app/widgets/floating_button_notification.dart';
import 'package:sakinah_app/screens/notifications/notifications_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialMood;

  const MainScreen({super.key, this.initialMood});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(mood: widget.initialMood),
      const QuizListScreen(),
      const TestimonialsScreen(),
      const ArticleListScreen(),
      const ScenarioListScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      try {
        final count = await NotificationService.getUnreadCount(
          token: authProvider.token!,
        );
        if (mounted) {
          setState(() => _unreadNotificationsCount = count);
        }
      } catch (e) {
        // Silencieux
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isConnected = authProvider.isAuthenticated;
    final isAdmin = authProvider.currentUser?['role'] == 'ADMIN';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Écrans principaux
          _screens[_currentIndex],

          // Boutons flottants (seulement si connecté)
          if (isConnected) ...[
            // Bouton Notifications
            FloatingNotificationButton(
              unreadCount: _unreadNotificationsCount,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const NotificationsScreen(),
                    ),
                  ),
                );
                _loadUnreadCount(); // Recharger après retour
              },
            ),

            // Bouton Admin (si admin)
            if (isAdmin)
              FloatingAdminButton(
                onTap: () {
                  Navigator.pushNamed(context, '/admin-moderation');
                },
              ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded),
              label: 'Quiz',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Témoignages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: 'Articles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.theater_comedy_rounded),
              label: 'Scénarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat IA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
