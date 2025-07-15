import '../exports.dart';

/// Service for calling the user_phone_numbers_create Supabase RPC endpoint.
class PhoneNumbersCreateService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  PhoneNumbersCreateService(this._client);

  /// Calls the user_phone_numbers_create RPC and returns true if successful (status_code 200).
  Future<bool> createPhoneNumber({
    required String inputEncryptedPhoneNumber,
    required String inputPhoneNumber,
  }) async {
    log('[services/phone_numbers_create_service.dart][createPhoneNumber] Calling RPC for user_phone_numbers_create');
    log('[services/phone_numbers_create_service.dart][createPhoneNumber] Encrypted phone number length: ${inputEncryptedPhoneNumber.length}');
    log('[services/phone_numbers_create_service.dart][createPhoneNumber] Plain phone number: $inputPhoneNumber');

    try {
      final response = await _client.rpc('user_phone_numbers_create', params: {
        'input_encrypted_phone_number': inputEncryptedPhoneNumber,
        'input_phone_number': inputPhoneNumber,
      });

      log('[services/phone_numbers_create_service.dart][createPhoneNumber] Received response: $response');

      if (response == null) {
        log('❌ No response from user_phone_numbers_create');
        return false;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int;

        log('[services/phone_numbers_create_service.dart][createPhoneNumber] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ Phone number created successfully');
          return true;
        } else {
          log('❌ Phone number creation failed with status code: $statusCode');
          return false;
        }
      } else {
        // Handle case where response is not a list (single item)
        final statusCode = response['status_code'] as int;

        log('[services/phone_numbers_create_service.dart][createPhoneNumber] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ Phone number created successfully');
          return true;
        } else {
          log('❌ Phone number creation failed with status code: $statusCode');
          return false;
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in createPhoneNumber: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2024-12-30 20:30:00
