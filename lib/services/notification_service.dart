import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolinked/utils/app_navigator.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/feature/ask/ask_discussion_screen.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_screen.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'geolinked_high_importance_channel',
        'GeoLinked Notifications',
        description: 'Important notifications for GeoLinked.',
        importance: Importance.max,
      );

  Future<void> initialize() async {
    final bool firebaseReady = await _initFirebase();
    if (!firebaseReady) {
      return;
    }

    await _requestPermissions();
    await _initLocalNotifications();
    await _setupForegroundNotifications();
    await _setupFcmListeners();
    await _handleInitialMessage();
  }

  Future<void> saveTokenToDatabase() async {
    try {
      final String? token = await _messaging.getToken();
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (token != null && userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('FCM Token saved for user: $userId');
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<String?> getFcmToken() async {
    return _messaging.getToken();
  }

  Future<bool> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return true;
    } catch (error) {
      debugPrint('NotificationService init skipped: $error');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _setupForegroundNotifications() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _setupFcmListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final RemoteNotification? notification = message.notification;
      if (notification == null || kIsWeb) {
        return;
      }

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    final String? type = data['type']; // 'ask' or 'broadcast'
    final String? id = data['id'];

    if (id == null || type == null || navigatorKey.currentState == null) {
      return;
    }

    if (type == 'ask') {
      // In a real app, you'd fetch the full model from Firestore first
      // For now, we'll navigate with a partial model or wait for fetch
      _navigateToAsk(id);
    } else if (type == 'broadcast') {
      _navigateToBroadcast(id);
    }
  }

  Future<void> _navigateToAsk(String id) async {
    final doc = await FirebaseFirestore.instance.collection('asks').doc(id).get();
    if (doc.exists) {
      final model = AskModel.fromJson(doc.data()!);
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AskDiscussionScreen(item: model)),
      );
    }
  }

  Future<void> _navigateToBroadcast(String id) async {
    final doc = await FirebaseFirestore.instance.collection('broadcasts').doc(id).get();
    if (doc.exists) {
      final model = BroadcastModel.fromJson(doc.data()!);
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => BroadcastDiscussionScreen(item: model)),
      );
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }
}
