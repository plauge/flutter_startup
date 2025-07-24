import '../exports.dart';

/// Service for calling the security_send_user_temporary_pin_code_for_phone_number_confirm Supabase RPC endpoint.
class PhoneNumberValidationSendPinService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  PhoneNumberValidationSendPinService(this._client);

  /// Calls the security_send_user_temporary_pin_code_for_phone_number_confirm RPC and returns true if successful (status_code 200).
  Future<bool> sendPinForPhoneNumberValidation({
    required String inputPhoneNumber,
  }) async {
    log('[services/phone_number_validation_send_pin_service.dart][sendPinForPhoneNumberValidation] Calling RPC for security_send_user_temporary_pin_code_for_phone_number_confirm');
    log('[services/phone_number_validation_send_pin_service.dart][sendPinForPhoneNumberValidation] Phone number: $inputPhoneNumber');

    try {
      final response = await _client.rpc('security_send_user_temporary_pin_code_for_phone_number_confirm', params: {
        'input_phone_number': inputPhoneNumber,
      });

      log('[services/phone_number_validation_send_pin_service.dart][sendPinForPhoneNumberValidation] Received response: $response');

      if (response == null) {
        log('❌ No response from security_send_user_temporary_pin_code_for_phone_number_confirm');
        return false;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int;

        log('[services/phone_number_validation_send_pin_service.dart][sendPinForPhoneNumberValidation] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ PIN code for phone number validation sent successfully');
          return true;
        } else {
          log('❌ PIN code for phone number validation sending failed with status code: $statusCode');
          return false;
        }
      } else {
        // Handle case where response is not a list (single item)
        final statusCode = response['status_code'] as int;

        log('[services/phone_number_validation_send_pin_service.dart][sendPinForPhoneNumberValidation] Status code: $statusCode');

        if (statusCode == 200) {
          log('✅ PIN code for phone number validation sent successfully');
          return true;
        } else {
          log('❌ PIN code for phone number validation sending failed with status code: $statusCode');
          return false;
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in sendPinForPhoneNumberValidation: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2025-01-28 11:30:00
