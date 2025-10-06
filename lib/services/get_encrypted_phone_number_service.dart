import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

/// Service for calling the get_encrypted_phone_number Supabase RPC endpoint.
class GetEncryptedPhoneNumberService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  GetEncryptedPhoneNumberService(this._client);

  /// Calls the get_encrypted_phone_number RPC and returns the encrypted phone number.
  Future<String?> getEncryptedPhoneNumber() async {
    log('[services/get_encrypted_phone_number_service.dart][getEncryptedPhoneNumber] Calling RPC for get_encrypted_phone_number');

    try {
      final response = await _client.rpc('get_encrypted_phone_number');

      log('[services/get_encrypted_phone_number_service.dart][getEncryptedPhoneNumber] Received response: $response');

      if (response == null) {
        log('❌ No response from get_encrypted_phone_number');
        return null;
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from get_encrypted_phone_number');
          return null;
        }
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;

        if (!data['success']) {
          log('❌ Operation not successful: ${data['message']}');
          return null;
        }

        final payload = data['payload'] as Map<String, dynamic>;
        final encryptedPhoneNumber = payload['encrypted_phone_number'] as String;
        log('✅ Successfully retrieved encrypted phone number');
        return encryptedPhoneNumber;
      }

      // Handle single object response
      final data = response['data'] as Map<String, dynamic>;
      if (!data['success']) {
        log('❌ Operation not successful: ${data['message']}');
        return null;
      }

      final payload = data['payload'] as Map<String, dynamic>;
      final encryptedPhoneNumber = payload['encrypted_phone_number'] as String;
      log('✅ Successfully retrieved encrypted phone number');
      return encryptedPhoneNumber;
    } catch (error, stackTrace) {
      log('❌ Error in getEncryptedPhoneNumber: $error\n$stackTrace');
      rethrow;
    }
  }
}

// File created: 2025-01-06 15:45:00
