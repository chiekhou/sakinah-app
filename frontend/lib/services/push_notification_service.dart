import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sakinah_app/services/api_service.dart';

/// Handler pour les messages en arrière-plan (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📱 Background message: ${message.notification?.title}');
}

/// Service pour gérer les notifications push via Firebase Cloud Messaging
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _fcmToken;
  static String? get fcmToken => _fcmToken;

  static bool _initialized = false;

  /// Initialiser le service de notifications push
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialiser Firebase (si pas déjà fait)
      await Firebase.initializeApp();
      debugPrint('📱 Firebase initialisé');

      // Configurer le handler pour les messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Demander les permissions
      await _requestPermissions();

      // Initialiser les notifications locales (pour foreground)
      await _initializeLocalNotifications();

      // Récupérer le token FCM
      await _getFCMToken();

      // Écouter le refresh du token
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('📱 Token FCM rafraîchi');
        _fcmToken = newToken;
        _sendTokenToServer(newToken);
      });

      // Gérer les messages en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Gérer le tap sur notification (app en background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Vérifier si l'app a été ouverte via une notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('📱 PushNotificationService initialisé');
    } catch (e) {
      debugPrint('📱 Erreur initialisation push: $e');
    }
  }

  /// Demander les permissions de notification
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📱 Permission: ${settings.authorizationStatus}');
  }

  /// Initialiser les notifications locales
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('📱 Notification locale tapée: ${response.payload}');
      },
    );

    // Créer le channel Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'sakinah_notifications',
        'Sakinah Notifications',
        description: 'Notifications de l\'app Sakinah',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Récupérer le token FCM
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('📱 FCM Token: ${_fcmToken?.substring(0, 20)}...');

      if (_fcmToken != null) {
        await _sendTokenToServer(_fcmToken!);
      }
    } catch (e) {
      debugPrint('📱 Erreur récupération token: $e');
    }
  }

  /// Envoyer le token au serveur
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await ApiService.getToken();
      if (authToken != null) {
        await ApiService.registerFCMToken(
          fcmToken: token,
          deviceType: Platform.isAndroid ? 'android' : 'ios',
        );
        debugPrint('📱 Token envoyé au serveur');
      }
    } catch (e) {
      debugPrint('📱 Erreur envoi token: $e');
    }
  }

  /// Gérer les messages en foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📱 Message foreground: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'sakinah_notifications',
            'Sakinah Notifications',
            channelDescription: 'Notifications de l\'app Sakinah',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Gérer le tap sur une notification
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📱 Notification tapée: ${message.data}');

    // TODO: Naviguer vers l'écran approprié selon le type de notification
    final type = message.data['type'];
    switch (type) {
      case 'TESTIMONIAL_APPROVED':
      case 'TESTIMONIAL_LIKED':
      case 'TESTIMONIAL_COMMENTED':
        // Naviguer vers le témoignage
        break;
      case 'DAILY_REMINDER':
        // Naviguer vers la page d'humeur
        break;
    }
  }

  /// Enregistrer le token après login
  static Future<void> registerTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _sendTokenToServer(_fcmToken!);
    }
  }

  /// Désinscrire le token (logout)
  static Future<void> unregisterToken() async {
    try {
      if (_fcmToken != null) {
        await ApiService.unregisterFCMToken(fcmToken: _fcmToken!);
        debugPrint('📱 Token désactivé sur le serveur');
      }
    } catch (e) {
      debugPrint('📱 Erreur désactivation token: $e');
    }
  }
}
