import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';

class AuthDeleteService {
  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient
  static final log = scopedLogger(LogCategory.service);

  AuthDeleteService(this._client);

  Future<bool> deleteUser() async {
    try {
      log('[services/auth_delete_service.dart][deleteUser] Attempting to delete user');
      final response = await _client.rpc('auth_delete_user');

      if (response != null && response is List && response.isNotEmpty) {
        final firstItem = response[0];
        if (firstItem is Map<String, dynamic> && firstItem.containsKey('data')) {
          final data = firstItem['data'];
          if (data is Map<String, dynamic> && data.containsKey('success')) {
            final success = data['success'] as bool;
            log('[services/auth_delete_service.dart][deleteUser] User deletion completed. Success: $success');
            return success;
          }
        }
      }
      log('[services/auth_delete_service.dart][deleteUser] Unexpected response format from delete user');
      return false;
    } on PostgrestException catch (error) {
      log('[services/auth_delete_service.dart][deleteUser] Database error during user deletion: $error');
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      log('[services/auth_delete_service.dart][deleteUser] Failed to delete user: $error');
      throw Exception('Failed to delete user: $error');
    }
  }
}
