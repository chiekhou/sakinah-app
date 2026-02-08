import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sakinah_app/screens/auth/email_verification_screen.dart';
import 'package:sakinah_app/screens/auth/forgot_password_screen.dart';
import 'package:sakinah_app/screens/auth/login_screen.dart';
import 'package:sakinah_app/screens/auth/register_screen.dart';
import 'package:sakinah_app/screens/home/splash_screen.dart';
import 'package:sakinah_app/screens/home/welcome_screen.dart';
import 'package:sakinah_app/screens/main_screen.dart';
import 'package:sakinah_app/screens/mood/mood_barometer_screen.dart';
//import 'package:sakinah_app/screens/mood/mascote_barometer_mascote_screen.dart';
import 'package:sakinah_app/providers/auth_provider.dart';
import 'package:sakinah_app/providers/mood_provider.dart';
import 'package:sakinah_app/constants/app_theme.dart';
import 'package:sakinah_app/screens/notifications/notifications_screen.dart';
import 'package:sakinah_app/screens/testimonials/my_testimonial_screen.dart';
import 'package:sakinah_app/screens/users/admin/admin_moderation_screen.dart';
import 'package:sakinah_app/screens/users/edit_profile_screen.dart';
import 'package:sakinah_app/screens/users/history_screen.dart';
import 'package:sakinah_app/screens/users/about_screen.dart';
import 'package:sakinah_app/screens/users/support_screen.dart';
import 'package:sakinah_app/screens/legal/privacy_policy_screen.dart';
import 'package:sakinah_app/screens/legal/terms_of_service_screen.dart';
import 'package:sakinah_app/services/deep_link_service.dart';
import 'package:sakinah_app/services/push_notification_service.dart';

void main() async {
  // Configuration de la barre de statut
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  // Utiliser --dart-define=ENV=production pour la production
  const String env = String.fromEnvironment('ENV', defaultValue: 'development');
  await dotenv.load(fileName: '.env.$env');

  // Initialiser les notifications push (Firebase)
  await PushNotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientation portrait uniquement
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    // Initialiser les deep links après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkService.init();
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
      ],
      child: MaterialApp(
        title: 'Sakinah - Bien-être Mental',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Clé de navigation pour les deep links
        navigatorKey: DeepLinkService.navigatorKey,

        // Routes
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/mood-navigator': (context) => const AppNavigator(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/my-testimonials': (context) => const MyTestimonialsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/admin-moderation': (context) => const AdminModerationScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/history': (context) => const HistoryScreen(),
          '/about': (context) => const AboutScreen(),
          '/support': (context) => const SupportScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
        },

        // Route avec arguments (email-verification)
        onGenerateRoute: (settings) {
          if (settings.name == '/email-verification') {
            final email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(email: email),
            );
          }
          return null;
        },

        // Gestion des routes inconnues
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        },
      ),
    );
  }
}

/// Navigateur principal qui gère le baromètre d'humeur
/// Après connexion/welcome, l'utilisateur choisit son humeur
/// puis accède à l'écran principal
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
    // Si l'humeur n'a pas encore été sélectionnée
    // Afficher le baromètre d'humeur
    if (!_hasSelectedMood) {
      return MoodBarometerScreen(onMoodSelected: _onMoodSelected);
    }

    // Une fois l'humeur sélectionnée
    // Naviguer vers l'écran principal avec l'humeur initiale
    return MainScreen(initialMood: _selectedMood);
  }
}
