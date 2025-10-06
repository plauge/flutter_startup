import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/user_notification_realtime_provider.g.dart';

@riverpod
UserNotificationRealtimeService userNotificationRealtimeService(Ref ref) {
  return UserNotificationRealtimeService(Supabase.instance.client);
}

@riverpod
class UserNotificationRealtimeNotifier extends _$UserNotificationRealtimeNotifier {
  @override
  AsyncValue<List<UserNotificationRealtime>> build() {
    return const AsyncValue.data([]);
  }

  /// Watches user notifications for a specific phone code ID
  Stream<List<UserNotificationRealtime>> watchUserNotifications(String phoneCodesId) {
    final log = scopedLogger(LogCategory.provider);
    log('[user_notification_realtime_provider.dart][watchUserNotifications] Starting to watch notifications for phone_codes_id: $phoneCodesId');

    final service = ref.watch(userNotificationRealtimeServiceProvider);
    return service.watchUserNotificationsByPhoneCodeId(phoneCodesId);
  }

  /// Loads initial user notifications for a specific phone code ID
  Future<void> loadUserNotifications(String phoneCodesId) async {
    final log = scopedLogger(LogCategory.provider);
    log('[user_notification_realtime_provider.dart][loadUserNotifications] Loading initial notifications for phone_codes_id: $phoneCodesId');

    state = const AsyncValue.loading();

    try {
      final service = ref.watch(userNotificationRealtimeServiceProvider);
      final notifications = await service.getUserNotificationsByPhoneCodeId(phoneCodesId);

      log('[user_notification_realtime_provider.dart][loadUserNotifications] Loaded ${notifications.length} notifications');
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      log('❌ [user_notification_realtime_provider.dart][loadUserNotifications] Error: $error');
      log('❌ [user_notification_realtime_provider.dart][loadUserNotifications] Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Updates the state with new notifications
  void updateNotifications(List<UserNotificationRealtime> notifications) {
    final log = scopedLogger(LogCategory.provider);
    log('[user_notification_realtime_provider.dart][updateNotifications] Updating with ${notifications.length} notifications');
    state = AsyncValue.data(notifications);
  }

  /// Resets the state to initial value
  void reset() {
    state = const AsyncValue.data([]);
  }
}

// Created: 2025-01-16 20:00:00
