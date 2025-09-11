import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/fcm_token_provider.g.dart';

@riverpod
class FCMTokenUpdate extends _$FCMTokenUpdate {
  static final log = scopedLogger(LogCategory.provider);

  @override
  FutureOr<bool> build() => false;

  /// Updates FCM token in Supabase user_extra table
  Future<bool> updateFCMToken(String fcmToken) async {
    log('[providers/fcm_token_provider.dart][updateFCMToken] Updating FCM token');

    try {
      final supabaseService = SupabaseService();
      final result = await supabaseService.updateFCMToken(fcmToken);

      log('[providers/fcm_token_provider.dart][updateFCMToken] FCM token update result: $result');
      return result;
    } catch (error, stackTrace) {
      log('❌ [providers/fcm_token_provider.dart][updateFCMToken] Error: $error');
      log('❌ [providers/fcm_token_provider.dart][updateFCMToken] Stack trace: $stackTrace');
      return false;
    }
  }
}

// Created: 2025-01-11 14:20:00
