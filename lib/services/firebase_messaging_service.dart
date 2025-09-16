import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import '../utils/app_logger.dart';
import 'supabase_service.dart';

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

      // iOS: Explicitly request permission to ensure visible prompt and proper authorization
      if (Platform.isIOS) {
        final iosSettings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        log('🕒 [$timestamp] iOS permission result: ${iosSettings.authorizationStatus}');

        // Ensure notifications are presented while app is in foreground
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Check current permission status
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      log('🕒 [$timestamp] Current permission status: ${settings.authorizationStatus}');
      log('🕒 [$timestamp] Alert allowed: ${settings.alert}');
      log('🕒 [$timestamp] Badge allowed: ${settings.badge}');
      log('🕒 [$timestamp] Sound allowed: ${settings.sound}');

      // iOS: CRITICAL for FCM v1 - MUST get APNS token before FCM token
      if (Platform.isIOS) {
        log('🕒 [$timestamp] iOS FCM v1: Getting APNS token first (ABSOLUTELY CRITICAL)...');
        String? apnsToken;
        int attempts = 0;
        const maxAttempts = 10; // Increased attempts for iOS

        // CRITICAL: Try multiple times to get APNS token (FCM v1 strict requirement)
        while (apnsToken == null && attempts < maxAttempts) {
          try {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken != null) {
              log('🍎✅ [$timestamp] APNS Token SUCCESS on attempt ${attempts + 1}');
              break;
            }
            attempts++;

            // Exponential backoff for iOS
            final delay = Duration(seconds: attempts * 2);
            log('🕒 [$timestamp] APNS Token attempt $attempts failed, waiting ${delay.inSeconds}s...');
            await Future.delayed(delay);
          } catch (apnsError) {
            log('🕒 [$timestamp] APNS Token attempt $attempts ERROR: $apnsError');
            attempts++;
            await Future.delayed(Duration(seconds: attempts * 2));
          }
        }

        if (apnsToken != null) {
          log('🍎🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢');
          log('🍎 iOS APNS Token SUCCESS! 🍎');
          log('🍎 Token Length: ${apnsToken.length}');
          log('🍎 Token Start: ${apnsToken.substring(0, min(20, apnsToken.length))}...');
          log('🍎🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢');
        } else {
          log('🍎🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴');
          log('🍎 iOS APNS Token FAILED after $maxAttempts attempts! 🍎');
          log('🍎 This will prevent FCM tokens from working on iOS! 🍎');
          log('🍎🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴');
        }

        // CRITICAL: Extra wait for iOS FCM v1 API to ensure proper token generation
        log('🍎 iOS FCM v1: Waiting 5 seconds for token stabilization...');
        await Future.delayed(const Duration(seconds: 5));
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

      // Automatically sync FCM token to Supabase if user is authenticated
      if (token != null) {
        await _syncFCMTokenToSupabase(token);
      }

      // Setup notification handlers
      _setupNotificationHandlers();

      // Setup FCM token refresh listener
      _setupTokenRefreshListener();

      // CRITICAL: Check notification permissions status
      await _checkNotificationPermissions();

      // CRITICAL DEBUG: iOS APNs Environment Check for FCM v1
      if (Platform.isIOS) {
        log('🍎📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋');
        log('🍎 iOS FCM v1 Environment Check:');
        log('🍎 Platform: iOS');
        log('🍎 APNs Environment: development (change to production for release)');
        log('🍎 Bundle ID: eu.idtruster.app');
        log('🍎 FCM Project ID: idtruster-push');
        log('🍎 Expected APNs certificate: iOS Development/Production');
        log('🍎 Push Capability: Should be enabled in Xcode');
        log('🍎 Background App Refresh: Should be enabled');
        log('🍎📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋📋');
      }
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
      log('\n\n');
      log('📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱');
      log('📱🕒 [$timestamp] FLUTTER FOREGROUND NOTIFICATION RECEIVED! 📱');
      log('🍎 Platform: ${Platform.isIOS ? 'iOS' : 'Android'}');
      log('📝 Message ID: ${message.messageId}');
      log('📤 From: ${message.from}');
      log('📦 Data: ${message.data}');
      log('📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱📱');
      log('\n\n');

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
        sound: RawResourceAndroidNotificationSound('beeb'),
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
          sound: RawResourceAndroidNotificationSound('beeb'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'beeb.wav',
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

  /// Setup FCM token refresh listener with automatic Supabase sync
  void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      final timestamp = DateTime.now().toIso8601String();
      log('🔄🕒 [$timestamp] FCM TOKEN REFRESHED');
      log('🔄 New Token: ${newToken.substring(0, 20)}...');

      // Automatically sync new token to Supabase if user is authenticated
      _syncFCMTokenToSupabase(newToken);
    });

    log('✅ FCM token refresh listener setup complete');
  }

  /// Sync FCM token to Supabase user_extra table (only if user authenticated)
  Future<void> _syncFCMTokenToSupabase(String fcmToken) async {
    try {
      // Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        log('ℹ️ FCM token sync skipped: No authenticated user');
        return;
      }

      log('🔄 Syncing FCM token to Supabase for user: ${user.email}');

      final supabaseService = SupabaseService();
      final result = await supabaseService.updateFCMToken(fcmToken);

      if (result) {
        log('✅ FCM token successfully synced to Supabase');
      } else {
        log('❌ FCM token sync to Supabase failed');
      }
    } catch (e) {
      log('❌ Error syncing FCM token to Supabase: $e');
    }
  }

  /// Check current notification permissions status
  Future<void> _checkNotificationPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      final timestamp = DateTime.now().toIso8601String();

      log('\n\n');
      log('🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔');
      log('🔔🕒 [$timestamp] NOTIFICATION PERMISSIONS CHECK 🔔');
      log('🔔 Authorization Status: ${settings.authorizationStatus}');
      log('🔔 Alert: ${settings.alert}');
      log('🔔 Badge: ${settings.badge}');
      log('🔔 Sound: ${settings.sound}');
      log('🔔 Announcement: ${settings.announcement}');
      log('🔔 Car Play: ${settings.carPlay}');
      log('🔔 Critical Alert: ${settings.criticalAlert}');
      log('🔔 Show Previews: ${settings.showPreviews}');
      log('🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔');

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        log('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️');
        log('⚠️ WARNING: Notifications not fully authorized! ⚠️');
        log('⚠️ Status: ${settings.authorizationStatus} ⚠️');
        log('⚠️ This will prevent notifications from showing! ⚠️');
        log('⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️');
      }
      log('\n\n');
    } catch (e) {
      log('❌ Error checking notification permissions: $e');
    }
  }
}

// Created on 2025-01-18 at 13:15
