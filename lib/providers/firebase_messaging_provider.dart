import 'package:firebase_messaging/firebase_messaging.dart';
import '../exports.dart';
import '../services/firebase_messaging_service.dart';

/// Provider for Firebase Cloud Messaging functionality
/// Handles initialization and notification handling
final firebaseMessagingProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});

/// Provider for initializing Firebase Messaging on app startup
/// This replaces the _initializeFirebaseMessaging() method from AuthNotifier
final firebaseMessagingInitProvider = FutureProvider<void>((ref) async {
  final log = scopedLogger(LogCategory.provider);
  AppLogger.logSeparator('Firebase Messaging Provider - Initialization');

  final service = ref.read(firebaseMessagingProvider);

  // Set up auth-specific notification handling
  service.setNotificationTapHandler((message) {
    _handleAuthNotificationTap(ref, message);
  });

  // Initialize Firebase Messaging (this replaces all the original FCM setup from AuthNotifier)
  await service.initialize();

  log('✅ Firebase Messaging initialized via FirebaseMessagingProvider');
});

/// Handle auth-specific notification taps
/// This function contains all the original notification tap handling logic
/// that was moved from AuthNotifier._handleNotificationTap
void _handleAuthNotificationTap(Ref ref, RemoteMessage message) {
  final log = scopedLogger(LogCategory.provider);
  AppLogger.logSeparator('Firebase Messaging Provider - Auth Notification Tap');

  final handleTapTimestamp = DateTime.now().toString();
  log('🎯 AUTH PROVIDER - HANDLING NOTIFICATION TAP ($handleTapTimestamp) - Data: ${message.data}');

  // Handle auth-specific notification actions (original logic preserved)
  final type = message.data['type'];
  final route = message.data['route'];

  if (type != null && route != null) {
    log('🧭 Auth Provider - Navigation type: $type, route: $route');
    // Here you could use GoRouter to navigate:
    // context.go(route);
    // Or trigger a specific action based on the type

    // Example: Handle auth-specific notification types (original logic)
    switch (type) {
      case 'auth_required':
        // Handle auth required notification
        log('🔐 Auth required notification received');
        break;
      case 'session_expired':
        // Handle session expired notification - trigger logout
        log('⏰ Session expired notification - signing out user');
        final authNotifier = ref.read(authProvider.notifier);
        authNotifier.signOut();
        break;
      default:
        log('ℹ️ Auth Provider - Unknown notification type: $type');
    }
  } else {
    log('ℹ️ Auth Provider - No navigation data in notification');
  }
}

// Created on 2025-01-18 at 13:30
