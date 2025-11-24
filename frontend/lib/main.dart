import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/screens/main_screen.dart';
import 'package:sakinah_app/screens/mood/mood_barometer_screen.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/providers/mood_provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MaterialApp(
        title: 'Bien-être Mental',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppNavigator(),
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int? _selectedMood;
  bool _hasSelectedMood = false;

  void _onMoodSelected(int mood) {
    setState(() {
      _selectedMood = mood;
      _hasSelectedMood = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSelectedMood) {
      return MoodBarometerScreen(onMoodSelected: _onMoodSelected);
    }

    return MainScreen(initialMood: _selectedMood);
  }
}
