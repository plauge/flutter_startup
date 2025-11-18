import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

/// Service for calling the security_update_user_extra_latest_load_if_recent Supabase RPC endpoint.
class SecurityUpdateUserExtraLatestLoadIfRecentService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  SecurityUpdateUserExtraLatestLoadIfRecentService(this._client);

  /// Calls the security_update_user_extra_latest_load_if_recent RPC endpoint.
  /// Returns true if the operation was successful, false otherwise.
  Future<bool> updateUserExtraLatestLoadIfRecent() async {
    log('[services/security_update_user_extra_latest_load_if_recent_service.dart][updateUserExtraLatestLoadIfRecent] Calling RPC for security_update_user_extra_latest_load_if_recent');

    try {
      final response = await _client.rpc('security_update_user_extra_latest_load_if_recent');

      log('[services/security_update_user_extra_latest_load_if_recent_service.dart][updateUserExtraLatestLoadIfRecent] Received response: $response');

      if (response == null) {
        log('❌ No response from security_update_user_extra_latest_load_if_recent');
        return false;
      }

      // Check if response indicates success
      if (response is List && response.isNotEmpty) {
        final firstItem = response[0] as Map<String, dynamic>;
        if (firstItem.containsKey('data')) {
          final data = firstItem['data'] as Map<String, dynamic>;
          final success = data['success'] as bool? ?? true;
          log('✅ Operation completed. Success: $success');
          return success;
        }
      }

      // If response doesn't have expected structure, assume success if response is not null
      log('✅ Operation completed (response received)');
      return true;
    } on PostgrestException catch (error, stackTrace) {
      log('❌ Database error in updateUserExtraLatestLoadIfRecent: ${error.message}\n$stackTrace');
      rethrow;
    } catch (error, stackTrace) {
      log('❌ Error in updateUserExtraLatestLoadIfRecent: $error\n$stackTrace');
      rethrow;
    }
  }
}

// File created: 2025-01-14 12:00:00

