import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../utils/app_logger.dart';

/// Service for handling Firebase Cloud Messaging (FCM) functionality
/// Manages push notifications for both iOS and Android platforms
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  static final log = scopedLogger(LogCategory.service);

  /// Callback function for handling notification taps
  /// Can be set from outside to handle navigation
  Function(RemoteMessage)? onNotificationTap;

  /// Initialize Firebase Messaging with FCM v1 API support
  Future<void> initialize() async {
    final timestamp = DateTime.now().toIso8601String();
    log('🕒 [$timestamp] FCM INITIALIZATION START (FCM v1 API)');
    AppLogger.logSeparator('FirebaseMessagingService initialize');

    try {
      log('🕒 [$timestamp] Requesting permissions...');

      // Request notification permission for Android 13+ and iOS
      if (Platform.isAndroid) {
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
        log('🕒 [$timestamp] Android notification permission requested');
      }

      // Firebase messaging permissions (critical for iOS with FCM v1)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      log('🕒 [$timestamp] Permission status: ${settings.authorizationStatus}');
      log('🕒 [$timestamp] Alert allowed: ${settings.alert}');
      log('🕒 [$timestamp] Badge allowed: ${settings.badge}');
      log('🕒 [$timestamp] Sound allowed: ${settings.sound}');
      log('🔔 Firebase Messaging permissions requested with FCM v1 settings');

      // iOS: Critical for FCM v1 - wait for APNS token before FCM token
      if (Platform.isIOS) {
        log('🕒 [$timestamp] iOS FCM v1: Getting APNS token first (CRITICAL)...');
        String? apnsToken;
        int attempts = 0;

        // Try multiple times to get APNS token (FCM v1 requirement)
        while (apnsToken == null && attempts < 5) {
          try {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) break;
            attempts++;
            await Future.delayed(Duration(seconds: attempts));
          } catch (apnsError) {
            log('🕒 [$timestamp] APNS Token attempt $attempts error: $apnsError');
            attempts++;
            await Future.delayed(Duration(seconds: attempts));
          }
        }

        log('🕒 [$timestamp] APNS Token: ${apnsToken != null ? 'RECEIVED ✅' : 'NULL ❌'}');
        if (apnsToken != null) {
          log('🕒 [$timestamp] APNS Token Length: ${apnsToken.length}');
          log('🕒 [$timestamp] APNS Token Start: ${apnsToken.substring(0, 10)}...');
        }

        // Extra wait for iOS FCM v1 API
        await Future.delayed(const Duration(seconds: 3));
      }

      log('🕒 [$timestamp] Getting FCM token (v1 API)...');
      // Get device FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      final tokenTimestampDetailed = DateTime.now().toString();
      log('🔥 FCM Token (v1 API) ($tokenTimestampDetailed): $token');

      // MEGA VISIBLE LOGGING - WORKS IN RELEASE MODE
      final tokenTimestamp = DateTime.now().toIso8601String();
      log('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
      log('🕒 [$tokenTimestamp] FCM TOKEN RESULT (v1 API):');
      log('TOKEN: ${token ?? 'NULL'}');
      log('STATUS: ${token != null ? 'SUCCESS ✅' : 'FAILED ❌'}');
      if (token != null) {
        log('LENGTH: ${token.length} characters');
        log('STARTS WITH: ${token.substring(0, 20)}...');
      }
      log('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');

      // FORCE LOG TO SYSTEM CONSOLE IN RELEASE
      if (token != null) {
        // Use developer.log which works in release mode
        developer.log('RELEASE FCM TOKEN (v1 API): $token', name: 'FCMToken');
      }

      AppLogger.logSeparator('FCM TOKEN FOR SUPABASE PUSH (v1 API)');
      log('===== KOPIER DETTE TOKEN TIL SUPABASE =====');
      log(token ?? 'NULL');
      log('============================================');
      AppLogger.logSeparator('');

      // Setup notification handlers
      _setupNotificationHandlers();

      // CRITICAL DEBUG: Check if iOS can connect to APNs
      log('🍎 iOS APNs Debug Check (FCM v1):');
      log('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Other'}');
      log('🍎 APNs Environment: development');
      log('🍎 Bundle ID: eu.idtruster.app');
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      log('\n\n');
      log('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      log('🕒 [$errorTimestamp] FCM ERROR:');
      log('ERROR: $e');
      log('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      log('\n\n');
      log('❌ Error initializing Firebase Messaging: $e');
    }
  }

  /// Set up notification handlers for foreground, background, and tap events
  void _setupNotificationHandlers() {
    AppLogger.logSeparator('FirebaseMessagingService _setupNotificationHandlers');

    // Create Android notification channel (required for Android 8.0+)
    if (Platform.isAndroid) {
      _createAndroidNotificationChannel();
    }

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final timestamp = DateTime.now().toIso8601String();
      log('\n\n📱🕒 [$timestamp] FLUTTER FOREGROUND NOTIFICATION 📱');
      log('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
      log('📝 Message ID: ${message.messageId}');
      log('📤 From: ${message.from}');
      log('📦 Data: ${message.data}');

      if (message.notification != null) {
        log('🔔 Title: ${message.notification!.title}');
        log('📄 Body: ${message.notification!.body}');
        log('🖼️ Image: ${message.notification!.android?.imageUrl ?? message.notification!.apple?.imageUrl ?? 'None'}');

        // iOS specific debugging
        if (Platform.isIOS) {
          log('🍎 iOS Notification Data:');
          log('🍎   - Badge: ${message.notification!.apple?.badge}');
          log('🍎   - Sound: ${message.notification!.apple?.sound}');
          log('🍎   - ImageUrl: ${message.notification!.apple?.imageUrl}');
        }
      }

      final foregroundTimestamp = DateTime.now().toString();
      log('📱 FLUTTER FOREGROUND NOTIFICATION ($foregroundTimestamp): ${message.notification?.title ?? 'No title'}');

      // Show notification even when app is in foreground (iOS doesn't do this by default)
      if (message.notification != null) {
        _showIOSNotification(message);
      }
    });

    // Handle notification tap when app is closed or in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final timestamp = DateTime.now().toIso8601String();
      log('\n\n🚀🕒 [$timestamp] NOTIFICATION TAPPED 🚀');
      log('📝 Message ID: ${message.messageId}');
      log('📦 Data: ${message.data}');

      if (message.notification != null) {
        log('🔔 Title: ${message.notification!.title}');
        log('📄 Body: ${message.notification!.body}');
      }

      final tapTimestamp = DateTime.now().toString();
      log('🚀 NOTIFICATION TAPPED ($tapTimestamp): ${message.notification?.title ?? 'No title'}');

      // Handle navigation based on notification data
      _handleNotificationTap(message);
    });

    // Check if app was launched from a notification (when app was terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final timestamp = DateTime.now().toIso8601String();
        log('\n\n🔄🕒 [$timestamp] APP LAUNCHED FROM NOTIFICATION 🔄');
        log('📝 Message ID: ${message.messageId}');
        log('📦 Data: ${message.data}');

        final launchTimestamp = DateTime.now().toString();
        log('🔄 APP LAUNCHED FROM NOTIFICATION ($launchTimestamp): ${message.notification?.title ?? 'No title'}');

        // Handle navigation based on notification data
        _handleNotificationTap(message);
      }
    });

    final setupCompleteTimestamp = DateTime.now().toString();
    log('✅ NOTIFICATION HANDLERS SETUP COMPLETE ($setupCompleteTimestamp)');
  }

  /// Create Android notification channel for high importance notifications
  Future<void> _createAndroidNotificationChannel() async {
    AppLogger.logSeparator('FirebaseMessagingService _createAndroidNotificationChannel');

    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // Must match the channel ID in AndroidManifest.xml
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      final channelTimestamp = DateTime.now().toString();
      log('✅ ANDROID NOTIFICATION CHANNEL CREATED ($channelTimestamp)');
      log('📢 Android notification channel "high_importance_channel" created');
    } catch (e) {
      log('❌ Error creating Android notification channel: $e');
      log('❌ Failed to create Android notification channel: $e');
    }
  }

  /// Show local notification using flutter_local_notifications
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Initialize plugin if not already done
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings optimized for FCM v1 API
      const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Show notification with optimized settings for iOS
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          subtitle: 'ID-Truster',
          threadIdentifier: 'idtruster_notifications',
        ),
      );

      // Use unique notification ID based on timestamp for iOS
      final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title ?? 'ID-Truster',
        message.notification?.body ?? 'New notification',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      log('🔔 Local notification displayed (ID: $notificationId): ${message.notification?.title}');
    } catch (e) {
      log('❌ Error showing local notification: $e');
      log('❌ Error showing local notification: $e');
    }
  }

  /// Show iOS notification using local notifications for foreground display
  Future<void> _showIOSNotification(RemoteMessage message) async {
    try {
      // For iOS: Use flutter_local_notifications to show notification
      // even when app is in foreground
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? 'New message';

      log('🍎 SHOWING iOS NOTIFICATION: $title - $body');

      if (Platform.isIOS) {
        // Use local notifications to display foreground notifications on iOS
        await _showLocalNotification(message);
        log('🔔 iOS local notification displayed: $title');
      }
    } catch (e) {
      log('❌ Error showing iOS notification: $e');
    }
  }

  /// Handle notification tap events and delegate to callback if set
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.logSeparator('FirebaseMessagingService _handleNotificationTap');
    final handleTapTimestamp = DateTime.now().toString();
    log('🎯 HANDLING NOTIFICATION TAP ($handleTapTimestamp) - Data: ${message.data}');

    // Delegate to callback if set
    if (onNotificationTap != null) {
      onNotificationTap!(message);
    } else {
      // Default handling
      final type = message.data['type'];
      final route = message.data['route'];

      if (type != null && route != null) {
        log('🧭 Navigation type: $type, route: $route');
        // Here you could use GoRouter to navigate:
        // context.go(route);
        // Or trigger a specific action based on the type
      } else {
        log('ℹ️ No navigation data in notification');
      }
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      log('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Set notification tap callback handler
  void setNotificationTapHandler(Function(RemoteMessage) handler) {
    onNotificationTap = handler;
  }
}

// Created on 2025-01-18 at 13:15
