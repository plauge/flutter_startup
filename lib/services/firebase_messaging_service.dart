import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import '../utils/app_logger.dart';
import 'fcm_token_lifecycle_service.dart';

/// Service for handling Firebase Cloud Messaging (FCM) functionality
/// Manages push notifications for both iOS and Android platforms
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  static final log = scopedLogger(LogCategory.service);

  /// Flutter Local Notifications plugin instance (initialized once)
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Whether flutter_local_notifications has been initialized
  bool _isLocalNotificationsInitialized = false;

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

        // NOTE: We do NOT use setForegroundNotificationPresentationOptions here
        // because we handle foreground notifications manually via _showLocalNotification
        // to ensure consistent sound playback and avoid duplicate notifications
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

      // Automatically sync FCM token to Supabase if user is authenticated using lifecycle service
      if (token != null) {
        await FCMTokenLifecycleService.instance.forceSyncFCMToken();
      }

      // Initialize flutter_local_notifications plugin
      await _initializeLocalNotifications();

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

  /// Initialize flutter_local_notifications plugin (called once at startup)
  Future<void> _initializeLocalNotifications() async {
    if (_isLocalNotificationsInitialized) {
      log('✅ flutter_local_notifications already initialized');
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_notification');

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

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
      _isLocalNotificationsInitialized = true;
      log('✅ flutter_local_notifications initialized successfully');
    } catch (e) {
      log('❌ Error initializing flutter_local_notifications: $e');
    }
  }

  /// Set up notification handlers for foreground, background, and tap events
  void _setupNotificationHandlers() {
    AppLogger.logSeparator('FirebaseMessagingService _setupNotificationHandlers');

    // Create Android notification channel (required for Android 8.0+)
    // CRITICAL: Channel must be created BEFORE setting up handlers to ensure it exists
    if (Platform.isAndroid) {
      _createAndroidNotificationChannel();
    }

    // Handle notification when app is in foreground
    // This handler ensures notifications are shown AND sound is played when app is active
    // Works for both iOS and Android
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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
          final AppleNotificationSound? soundObj = message.notification!.apple?.sound;
          log('🍎   - Sound object: $soundObj');
          log('🍎   - Sound type: ${soundObj.runtimeType}');
          if (soundObj != null) {
            try {
              log('🍎   - Sound.name: ${soundObj.name}');
            } catch (e) {
              log('🍎   - Sound.name error: $e');
            }
            log('🍎   - Sound.toString(): ${soundObj.toString()}');
          } else {
            log('🍎   - Sound object is NULL - checking data payload...');
            log('🍎   - message.data keys: ${message.data.keys}');
            log('🍎   - message.data values: ${message.data.values}');
          }
          log('🍎   - ImageUrl: ${message.notification!.apple?.imageUrl}');
        }
      }

      final foregroundTimestamp = DateTime.now().toString();
      log('📱 FLUTTER FOREGROUND NOTIFICATION ($foregroundTimestamp): ${message.notification?.title ?? 'No title'}');

      // Show notification even when app is in foreground (both iOS and Android)
      // This ensures notifications are always visible and sound is always played
      // Sound is extracted from message.data['sound'] or platform-specific notification sound
      if (message.notification != null) {
        await _showLocalNotification(message);
      }
    });

    // Handle notification tap when app is in background (not terminated)
    // When app is in background, system automatically shows notification with sound from Firebase payload
    // Sound must be in: apns.payload.aps.sound (iOS) or android.notification.sound (Android)
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
    // When app is terminated, system automatically shows notification with sound from Firebase payload
    // Sound must be in: apns.payload.aps.sound (iOS) or android.notification.sound (Android)
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

  /// Create Android notification channels for all possible sounds
  /// CRITICAL: On Android 8.0+, when app is in background, Android uses channels directly from Firebase
  /// We must pre-create channels for all sounds so they're available for background notifications
  Future<void> _createAndroidNotificationChannel() async {
    AppLogger.logSeparator('FirebaseMessagingService _createAndroidNotificationChannel');

    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation == null) {
        log('❌ Android implementation not available');
        return;
      }

      // List of all available sound files (without extension)
      final List<String> soundFiles = ['idtruster1', 'classicphone', 'alert', 'confirmed'];
      log('🔊 DEBUG: Creating channels for ${soundFiles.length} sound files');

      // Create a channel for each sound file
      for (final soundFile in soundFiles) {
        final channelId = 'high_importance_channel_$soundFile';

        try {
          // Delete existing channel if it exists
          try {
            await androidImplementation.deleteNotificationChannel(channelId);
            log('🗑️ Deleted existing channel "$channelId" (if it existed)');
            await Future.delayed(const Duration(milliseconds: 50));
          } catch (e) {
            // Channel might not exist, that's ok
          }

          // Create channel with sound set directly on the channel
          final AndroidNotificationChannel channel = AndroidNotificationChannel(
            channelId,
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(soundFile),
            enableVibration: true,
            showBadge: true,
          );

          await androidImplementation.createNotificationChannel(channel);
          log('✅ Created channel "$channelId" with sound "$soundFile"');
        } catch (e) {
          log('❌ Error creating channel "$channelId" for sound "$soundFile": $e');
        }
      }

      // CRITICAL: Also create the default channel (matches AndroidManifest.xml)
      // This is used when Firebase sends background notifications
      // We set the most commonly used sound (idtruster1) on this channel
      try {
        await androidImplementation.deleteNotificationChannel('high_importance_channel');
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (e) {
        // Channel might not exist, that's ok
      }

      // Create default channel with most commonly used sound (idtruster1)
      // This ensures background notifications use the correct sound
      final AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        'high_importance_channel', // Must match the channel ID in AndroidManifest.xml
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('idtruster1'), // Most common sound
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(defaultChannel);
      log('✅ Created default channel "high_importance_channel" with sound "idtruster1"');
      log('🔊 DEBUG: Default channel will be used for background notifications');
      log('⚠️ IMPORTANT: For background notifications to use correct sound, Firebase must send:');
      log('⚠️   android.notification.channel_id = "high_importance_channel_<soundname>"');
      log('⚠️   Example: android.notification.channel_id = "high_importance_channel_idtruster1"');
      log('⚠️   If channel_id is not specified, Android uses default channel with "idtruster1" sound');

      final channelTimestamp = DateTime.now().toString();
      log('✅ ALL ANDROID NOTIFICATION CHANNELS CREATED ($channelTimestamp)');
      log('📢 Created ${soundFiles.length + 1} notification channels (one per sound + default)');
      log('🔊 Channels are ready for both foreground and background notifications');
    } catch (e) {
      log('❌ Error creating Android notification channels: $e');
      log('❌ Failed to create Android notification channels: $e');
    }
  }

  /// Extract sound filename from Firebase message
  /// Priority: 1) message.data['sound'] (REQUIRED for Flutter foreground notifications), 2) platform notification sound
  /// Returns empty string if no sound found (will use system default)
  ///
  /// IMPORTANT: Firebase payload MUST include "data": {"sound": "filename.wav"} for custom sounds to work in Flutter.
  /// The apns.payload.aps.sound is NOT accessible in Flutter's RemoteMessage when app is in foreground.
  /// Example Firebase payload:
  /// {
  ///   "message": {
  ///     "data": {"sound": "idtruster1.wav"},
  ///     "apns": {"payload": {"aps": {"sound": "idtruster1.wav"}}}
  ///   }
  /// }
  String _getSoundFromMessage(RemoteMessage message) {
    log('🔊 DEBUG: Extracting sound from message...');
    log('🔊 DEBUG: message.data = ${message.data}');
    log('🔊 DEBUG: message.data keys = ${message.data.keys.toList()}');

    // First check data payload (highest priority)
    final Object? soundFromData = message.data['sound'];
    log('🔊 DEBUG: soundFromData = $soundFromData');
    if (soundFromData != null && soundFromData.toString().isNotEmpty) {
      log('🔊 Sound from data payload: $soundFromData');
      return soundFromData.toString();
    }

    // Then check platform-specific notification sound
    if (Platform.isAndroid) {
      final String? soundFromAndroid = message.notification?.android?.sound;
      log('🔊 DEBUG: soundFromAndroid = $soundFromAndroid');
      if (soundFromAndroid != null && soundFromAndroid.isNotEmpty) {
        log('🔊 Sound from Android notification: $soundFromAndroid');
        return soundFromAndroid;
      }
    }

    if (Platform.isIOS) {
      final AppleNotificationSound? soundFromIOS = message.notification?.apple?.sound;
      log('🔊 DEBUG: soundFromIOS object = $soundFromIOS');
      log('🔊 DEBUG: soundFromIOS type = ${soundFromIOS.runtimeType}');

      if (soundFromIOS != null) {
        // Try to get name property - this is the actual sound filename
        try {
          final String? soundName = soundFromIOS.name;
          log('🔊 DEBUG: soundFromIOS.name = $soundName');
          if (soundName != null && soundName.isNotEmpty && soundName != 'default' && soundName != 'custom') {
            log('🔊 Sound from iOS notification (name): $soundName');
            return soundName;
          }
        } catch (e) {
          log('🔊 DEBUG: Error accessing .name property: $e');
        }

        // Fallback to toString
        try {
          final String soundString = soundFromIOS.toString();
          log('🔊 DEBUG: soundFromIOS.toString() = $soundString');
          if (soundString.isNotEmpty && soundString != 'null' && !soundString.contains('AppleNotificationSound') && soundString != 'default' && soundString != 'custom') {
            log('🔊 Sound from iOS notification (toString): $soundString');
            return soundString;
          }
        } catch (e) {
          log('🔊 DEBUG: Error calling toString(): $e');
        }

        log('🔊 DEBUG: Could not extract sound from AppleNotificationSound object - it shows as "custom"');
        log('🔊 DEBUG: This means Firebase sent a custom sound but Flutter cannot read it from RemoteMessage');
        log('🔊 DEBUG: Solution: Add "data": {"sound": "idtruster1.wav"} to Firebase payload');
      } else {
        log('🔊 DEBUG: message.notification?.apple?.sound is null');
      }
    }

    // CRITICAL: No fallback sound - only use sound from Firebase payload
    // If no sound is specified, return empty string (will use system default)
    // NOTE: For custom sounds to work, Firebase payload MUST include "data": {"sound": "filename.wav"}
    // The apns.payload.aps.sound is not accessible in Flutter's RemoteMessage in foreground
    log('⚠️ WARNING: No sound found in Firebase payload - will use system default sound');
    return '';
  }

  /// Normalize sound filename for platform requirements
  /// Android: remove extension, iOS: ensure .wav extension
  String _normalizeSoundForPlatform(String soundName, {required bool isAndroid}) {
    if (isAndroid) {
      // Android: Remove extension if present
      if (soundName.contains('.')) {
        return soundName.substring(0, soundName.lastIndexOf('.'));
      }
      return soundName;
    } else {
      // iOS: Ensure .wav extension
      String baseName = soundName;
      if (soundName.contains('.')) {
        baseName = soundName.substring(0, soundName.lastIndexOf('.'));
      }
      // Only add .wav if it doesn't already have it
      if (!soundName.toLowerCase().endsWith('.wav')) {
        return '$baseName.wav';
      }
      return soundName;
    }
  }

  /// Create or get Android notification channel with specific sound
  /// CRITICAL: On Android 8.0+, sound MUST be set on the channel, not just the notification
  Future<String> _getOrCreateChannelForSound(String soundName) async {
    log('🔊 DEBUG: _getOrCreateChannelForSound called with soundName: "$soundName"');

    if (soundName.isEmpty) {
      log('🔊 DEBUG: soundName is empty, using default channel');
      return 'high_importance_channel'; // Use default channel if no sound
    }

    // Create unique channel ID based on sound name
    final channelId = 'high_importance_channel_$soundName';
    log('🔊 DEBUG: Generated channelId: "$channelId"');

    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation == null) {
        log('❌ Android implementation not available, using default channel');
        return 'high_importance_channel';
      }

      log('🔊 DEBUG: Attempting to delete existing channel "$channelId" (if it exists)');
      // Delete existing channel if it exists (to recreate with correct sound)
      try {
        await androidImplementation.deleteNotificationChannel(channelId);
        log('🗑️ Successfully deleted existing channel "$channelId"');
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        log('ℹ️ Channel "$channelId" did not exist (or deletion failed): $e');
        // Channel might not exist, that's ok
      }

      log('🔊 DEBUG: Creating new channel "$channelId" with sound "$soundName"');
      log('🔊 DEBUG: Sound file should exist at: android/app/src/main/res/raw/$soundName.wav');

      // Create channel with sound set directly on the channel
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundName), // CRITICAL: Set sound on channel!
        enableVibration: true,
        showBadge: true,
      );

      log('🔊 DEBUG: Channel object created with:');
      log('🔊 DEBUG:   - ID: ${channel.id}');
      log('🔊 DEBUG:   - Name: ${channel.name}');
      log('🔊 DEBUG:   - Importance: ${channel.importance}');
      log('🔊 DEBUG:   - playSound: ${channel.playSound}');
      log('🔊 DEBUG:   - sound: ${channel.sound}');
      log('🔊 DEBUG:   - enableVibration: ${channel.enableVibration}');
      log('🔊 DEBUG:   - showBadge: ${channel.showBadge}');

      await androidImplementation.createNotificationChannel(channel);
      log('✅ Successfully created notification channel "$channelId" with sound "$soundName"');
      log('🔊 DEBUG: Channel creation completed - sound should now be set on channel');
      return channelId;
    } catch (e, stackTrace) {
      log('❌ Error creating channel for sound "$soundName": $e');
      log('❌ Stack trace: $stackTrace');
      log('⚠️ Falling back to default channel "high_importance_channel"');
      return 'high_importance_channel'; // Fallback to default channel
    }
  }

  /// Show local notification using flutter_local_notifications
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Ensure plugin is initialized (should already be done at startup)
      if (!_isLocalNotificationsInitialized) {
        log('⚠️ flutter_local_notifications not initialized, initializing now...');
        await _initializeLocalNotifications();
      }

      // Get sound name from Firebase message
      // IMPORTANT: Firebase payload must include "data": {"sound": "classicphone.wav"}
      // for Flutter to read it in foreground. The apns.payload.aps.sound is not accessible in Flutter.
      log('🔊 DEBUG: About to extract sound from message');
      log('🔊 DEBUG: message.data = ${message.data}');
      log('🔊 DEBUG: message.data keys = ${message.data.keys.toList()}');
      final String soundName = _getSoundFromMessage(message);
      log('🔊 DEBUG: Extracted soundName = $soundName');
      final String androidSound = _normalizeSoundForPlatform(soundName, isAndroid: true);
      final String iosSound = _normalizeSoundForPlatform(soundName, isAndroid: false);
      log('🔊 Using sound - Android: $androidSound, iOS: $iosSound');
      log('🔊 Android sound file should be in: android/app/src/main/res/raw/$androidSound.wav');

      // CRITICAL: On Android 8.0+, sound MUST be set on the channel, not just the notification
      // Create or get channel with the specific sound
      log('🔊 DEBUG: About to create/get channel for sound: "$androidSound"');
      final String channelId = await _getOrCreateChannelForSound(androidSound);
      log('🔊 DEBUG: Received channel ID: "$channelId"');
      log('🔊 Using channel ID: $channelId');

      // CRITICAL: Validate sound file name for Android
      if (androidSound.isEmpty) {
        log('⚠️ WARNING: Android sound name is empty - Firebase payload missing sound!');
        log('⚠️ Will use system default sound (not custom sound)');
      }

      // Show notification with dynamic sound from FCM payload
      // CRITICAL: On Android 8.0+, sound is set on the channel, not here
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, // Use the channel we just created with the sound
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          enableVibration: true,
          playSound: true,
          // Sound is set on channel, not here (Android 8+ requirement)
          sound: null,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: iosSound,
          badgeNumber: 1,
          subtitle: 'ID-Truster',
          threadIdentifier: 'idtruster_notifications',
        ),
      );

      // Use unique notification ID based on timestamp for iOS
      final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;

      log('🔔 About to show notification with sound: $androidSound');
      log('🔊 Android notification details:');
      log('🔊   - Channel ID: $channelId (created with sound "$androidSound")');
      log('🔊   - Sound: Set on channel (Android 8+ requirement)');
      log('🔊   - Sound file: android/app/src/main/res/raw/$androidSound.wav');
      log('🔊   - playSound: true');
      log('🔊   - Importance: high');
      log('🔊   - Priority: high');
      log('🔊   - Notification sound parameter: null (sound is on channel)');

      try {
        await _flutterLocalNotificationsPlugin.show(
          notificationId,
          message.notification?.title ?? 'ID-Truster',
          message.notification?.body ?? 'New notification',
          platformChannelSpecifics,
          payload: message.data.toString(),
        );

        log('✅ Local notification displayed successfully (ID: $notificationId): ${message.notification?.title}');
        log('🔊 DEBUG: Notification shown with:');
        log('🔊 DEBUG:   - Channel ID: $channelId');
        log('🔊 DEBUG:   - Sound name: $androidSound');
        log('🔊 DEBUG:   - Sound file path: android/app/src/main/res/raw/$androidSound.wav');
        log('🔊 Sound should have played: $androidSound');
        log('🔊 DEBUG: If sound did not play, verify:');
        log('🔊 DEBUG:   1. File exists in android/app/src/main/res/raw/$androidSound.wav');
        log('🔊 DEBUG:   2. File format is PCM, 16-bit, mono/stereo, ≤48kHz');
        log('🔊 DEBUG:   3. Channel "$channelId" was created with sound "$androidSound"');
        log('🔊 DEBUG:   4. Channel has playSound: true');
        log('🔊 DEBUG:   5. Channel has sound: RawResourceAndroidNotificationSound("$androidSound")');
        log('🔊 DEBUG:   6. Device notification settings allow sounds for this app');
        log('🔊 DEBUG:   7. Check device settings: Settings > Apps > ID-Truster > Notifications > "$channelId"');
      } catch (e) {
        log('❌ Error showing notification: $e');
        log('❌ Error details: $e');
        rethrow;
      }
    } catch (e) {
      log('❌ Error showing local notification: $e');
      log('❌ Error showing local notification: $e');
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

      // Automatically sync new token to Supabase if user is authenticated using lifecycle service
      FCMTokenLifecycleService.instance.forceSyncFCMToken();
    });

    log('✅ FCM token refresh listener setup complete');
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
