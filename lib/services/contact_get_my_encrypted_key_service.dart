import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import 'logged_supabase_client.dart';

/// Service for calling the contact_get_my_encrypted_key_for_contact Supabase RPC endpoint.
class ContactGetMyEncryptedKeyService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  ContactGetMyEncryptedKeyService(this._client);

  /// Calls the contact_get_my_encrypted_key_for_contact RPC with the given contact user ID and returns the encrypted_key string.
  Future<String?> getMyEncryptedKeyForContact(String inputMyContactUserId) async {
    log('[services/contact_get_my_encrypted_key_service.dart][getMyEncryptedKeyForContact] Calling RPC for contact user ID: $inputMyContactUserId');

    try {
      final response = await _client.rpc(
        'contact_get_my_encrypted_key_for_contact',
        params: {'input_my_contact_user_id': inputMyContactUserId},
      );

      log('[services/contact_get_my_encrypted_key_service.dart][getMyEncryptedKeyForContact] Received response: $response');

      if (response == null) {
        log('❌ No response from contact_get_my_encrypted_key_for_contact');
        return null;
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from contact_get_my_encrypted_key_for_contact');
          return null;
        }
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;

        if (!data['success']) {
          log('❌ Operation not successful: ${data['message']}');
          return null;
        }

        final payload = data['payload'] as Map<String, dynamic>;
        final encryptedKey = payload['encrypted_key'] as String;
        log('✅ Successfully retrieved encrypted key');
        return encryptedKey;
      }

      // Handle single object response
      final data = response['data'] as Map<String, dynamic>;
      if (!data['success']) {
        log('❌ Operation not successful: ${data['message']}');
        return null;
      }

      final payload = data['payload'] as Map<String, dynamic>;
      final encryptedKey = payload['encrypted_key'] as String;
      log('✅ Successfully retrieved encrypted key');
      return encryptedKey;
    } catch (e, stackTrace) {
      log('❌ Error in getMyEncryptedKeyForContact: $e');
      log('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
}

// File created: 2025-10-07 14:30:00


