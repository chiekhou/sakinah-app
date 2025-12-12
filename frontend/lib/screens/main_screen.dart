import 'package:flutter/material.dart';
import 'package:sakinah_app/screens/chat/chat_screen.dart';
import 'package:sakinah_app/screens/quiz/quiz_list_screen.dart';
import 'package:sakinah_app/screens/articles/articles_list_screen.dart';
import 'package:sakinah_app/screens/scenarios/scenarios_list_screen.dart';
import 'package:sakinah_app/screens/home/home_screen.dart';
import 'package:sakinah_app/constants/app_theme.dart';

class MainScreen extends StatefulWidget {
  final int? initialMood;

  const MainScreen({super.key, this.initialMood});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(mood: widget.initialMood),
      QuizListScreen(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ArticleListScreen(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ScenarioListScreen(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ChatScreen(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
          selectedFontSize: 12,
          unselectedFontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
