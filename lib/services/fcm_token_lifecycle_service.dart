import '../exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMTokenLifecycleService extends WidgetsBindingObserver {
  static final log = scopedLogger(LogCategory.service);
  static FCMTokenLifecycleService? _instance;
  static String? _lastSyncedToken;

  FCMTokenLifecycleService._();

  static FCMTokenLifecycleService get instance {
    _instance ??= FCMTokenLifecycleService._();
    return _instance!;
  }

  /// Initialize lifecycle monitoring
  void initialize() {
    log('lib/services/fcm_token_lifecycle_service.dart: Initializing FCM token lifecycle monitoring');
    WidgetsBinding.instance.addObserver(this);

    // Listen to Supabase auth state changes for session renewal
    _setupAuthStateListener();
  }

  /// Cleanup lifecycle monitoring
  void dispose() {
    log('lib/services/fcm_token_lifecycle_service.dart: Disposing FCM token lifecycle monitoring');
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        log('📱 lib/services/fcm_token_lifecycle_service.dart: App resumed - syncing FCM token');
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        log('📱 lib/services/fcm_token_lifecycle_service.dart: App paused');
        break;
      default:
        break;
    }
  }

  /// Handle app resumed from background
  void _handleAppResumed() async {
    try {
      // Short delay to ensure app is fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        log('ℹ️ lib/services/fcm_token_lifecycle_service.dart: User not authenticated, skipping FCM sync');
        return;
      }

      await _syncFCMTokenIfNeeded();
    } catch (e) {
      log('❌ lib/services/fcm_token_lifecycle_service.dart: Error handling app resumed: $e');
    }
  }

  /// Setup Supabase auth state listener for session renewal
  void _setupAuthStateListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((AuthState authState) {
      if (authState.event == AuthChangeEvent.tokenRefreshed) {
        log('🔄 lib/services/fcm_token_lifecycle_service.dart: Supabase session refreshed - syncing FCM token');
        _syncFCMTokenIfNeeded();
      }
    });
  }

  /// Sync FCM token if it has changed or never been synced
  Future<void> _syncFCMTokenIfNeeded() async {
    try {
      final currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken == null) {
        log('❌ lib/services/fcm_token_lifecycle_service.dart: No FCM token available');
        return;
      }

      // Check if token has changed
      if (_lastSyncedToken == currentToken) {
        log('ℹ️ lib/services/fcm_token_lifecycle_service.dart: FCM token unchanged, skipping sync');
        return;
      }

      log('🔄 lib/services/fcm_token_lifecycle_service.dart: FCM token changed, syncing to Supabase');

      final supabaseService = SupabaseService();
      final result = await supabaseService.updateFCMToken(currentToken);

      if (result) {
        _lastSyncedToken = currentToken;
        log('✅ lib/services/fcm_token_lifecycle_service.dart: FCM token synced successfully');
      } else {
        log('❌ lib/services/fcm_token_lifecycle_service.dart: FCM token sync failed');
      }
    } catch (e) {
      log('❌ lib/services/fcm_token_lifecycle_service.dart: Error syncing FCM token: $e');
    }
  }

  /// Force sync FCM token (for manual triggers)
  Future<bool> forceSyncFCMToken() async {
    try {
      log('🔄 lib/services/fcm_token_lifecycle_service.dart: Force syncing FCM token');

      final currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken == null) {
        log('❌ lib/services/fcm_token_lifecycle_service.dart: No FCM token available for force sync');
        return false;
      }

      final supabaseService = SupabaseService();
      final result = await supabaseService.updateFCMToken(currentToken);

      if (result) {
        _lastSyncedToken = currentToken;
        log('✅ lib/services/fcm_token_lifecycle_service.dart: Force FCM token sync successful');
        return true;
      } else {
        log('❌ lib/services/fcm_token_lifecycle_service.dart: Force FCM token sync failed');
        return false;
      }
    } catch (e) {
      log('❌ lib/services/fcm_token_lifecycle_service.dart: Error in force FCM token sync: $e');
      return false;
    }
  }
}

// Created: 2025-01-17 16:30:00
