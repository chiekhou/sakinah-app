import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/screens/mood_barometer_screen.dart';
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
        home: const MoodBarometerScreen(),
      ),
    );
  }
}
