import '../exports.dart';

/// Service for calling the user_phone_numbers_delete Supabase RPC endpoint.
class PhoneNumbersDeleteService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  PhoneNumbersDeleteService(this._client);

  /// Calls the user_phone_numbers_delete RPC and returns true if successful (status_code 200).
  Future<bool> deletePhoneNumber({
    required String inputPhoneNumber,
  }) async {
    log('[services/phone_numbers_delete_service.dart][deletePhoneNumber] Calling RPC for user_phone_numbers_delete');
    log('[services/phone_numbers_delete_service.dart][deletePhoneNumber] Phone number: $inputPhoneNumber');

    try {
      final response = await _client.rpc('user_phone_numbers_delete', params: {
        'input_phone_number': inputPhoneNumber,
      });

      log('[services/phone_numbers_delete_service.dart][deletePhoneNumber] Received response: $response');

      if (response == null) {
        log('❌ No response from user_phone_numbers_delete');
        return false;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int;

        log('[services/phone_numbers_delete_service.dart][deletePhoneNumber] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ Phone number deleted successfully');
          return true;
        } else {
          log('❌ Phone number deletion failed with status code: $statusCode');
          return false;
        }
      } else {
        // Handle case where response is not a list (single item)
        final statusCode = response['status_code'] as int;

        log('[services/phone_numbers_delete_service.dart][deletePhoneNumber] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ Phone number deleted successfully');
          return true;
        } else {
          log('❌ Phone number deletion failed with status code: $statusCode');
          return false;
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in deletePhoneNumber: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2024-12-30 20:45:00
