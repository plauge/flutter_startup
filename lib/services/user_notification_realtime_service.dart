import 'dart:async';
import '../exports.dart';

class UserNotificationRealtimeService {
  static final log = scopedLogger(LogCategory.service);
  final SupabaseClient _client;

  UserNotificationRealtimeService(this._client);

  /// Creates a realtime stream for user_notification_realtime filtered by phone_codes_id
  Stream<List<UserNotificationRealtime>> watchUserNotificationsByPhoneCodeId(String phoneCodesId) {
    final user = _client.auth.currentUser;
    if (user == null) {
      log('[user_notification_realtime_service.dart][watchUserNotificationsByPhoneCodeId] No authenticated user');
      return Stream.value([]);
    }

    log('[user_notification_realtime_service.dart][watchUserNotificationsByPhoneCodeId] Starting realtime stream for phone_codes_id: $phoneCodesId');

    return _client.from('user_notification_realtime').stream(primaryKey: ['user_notification_realtime_id']).eq('phone_codes_id', phoneCodesId).map((data) {
          log('[user_notification_realtime_service.dart][watchUserNotificationsByPhoneCodeId] Realtime update received: ${data.length} items for phone_codes_id: $phoneCodesId');
          log('[user_notification_realtime_service.dart][watchUserNotificationsByPhoneCodeId] Raw data: $data');
          final notifications = data.map((json) => UserNotificationRealtime.fromJson(json)).toList();
          for (final notification in notifications) {
            log('[user_notification_realtime_service.dart][watchUserNotificationsByPhoneCodeId] Parsed notification: action=${notification.action}, encrypted_phone_number=${notification.encryptedPhoneNumber}');
          }
          return notifications;
        });
  }

  /// Fetches all user_notification_realtime records for a specific phone_codes_id
  Future<List<UserNotificationRealtime>> getUserNotificationsByPhoneCodeId(String phoneCodesId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        log('[user_notification_realtime_service.dart][getUserNotificationsByPhoneCodeId] No authenticated user');
        return [];
      }

      log('[user_notification_realtime_service.dart][getUserNotificationsByPhoneCodeId] Loading user notifications for phone_codes_id: $phoneCodesId');

      final response = await _client.from('user_notification_realtime').select('*').eq('phone_codes_id', phoneCodesId).order('created_at', ascending: false);

      log('[user_notification_realtime_service.dart][getUserNotificationsByPhoneCodeId] Response received: ${response.length} items');

      return response.map((json) => UserNotificationRealtime.fromJson(json)).toList();
    } catch (e, stack) {
      log('[user_notification_realtime_service.dart][getUserNotificationsByPhoneCodeId] Error: $e, Stack: $stack');
      throw Exception('Failed to load user notifications: $e');
    }
  }
}

// Created: 2025-01-16 20:00:00
