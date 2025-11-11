import '../exports.dart';
import 'logged_supabase_client.dart';

class PhoneCodeCreateService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  PhoneCodeCreateService(this._client);

  /// Calls the phone_codes_create_by_user RPC and returns true if successful (status_code 200).
  Future<bool> createPhoneCodeByUser({
    required String inputContactId,
  }) async {
    log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Calling RPC for phone_codes_create_by_user');
    log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Contact ID: $inputContactId');

    try {
      final response = await _client.rpc('phone_codes_create_by_user', params: {
        'input_contact_id': inputContactId,
      });

      log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Received response: $response');

      if (response == null) {
        log('❌ No response from phone_codes_create_by_user');
        return false;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int;

        log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Status code: $statusCode');

        if (statusCode == 200) {
          final data = firstItem['data'] as Map<String, dynamic>;
          final payload = data['payload'] as Map<String, dynamic>;
          log('✅ Phone code created successfully');
          log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Phone codes ID: ${payload['phone_codes_id']}');
          log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Confirm code: ${payload['confirm_code']}');
          return true;
        } else {
          log('❌ Phone code creation failed with status code: $statusCode');
          return false;
        }
      } else {
        // Handle case where response is not a list (single item)
        final statusCode = response['status_code'] as int;

        log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Status code: $statusCode');

        if (statusCode == 200) {
          final data = response['data'] as Map<String, dynamic>;
          final payload = data['payload'] as Map<String, dynamic>;
          log('✅ Phone code created successfully');
          log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Phone codes ID: ${payload['phone_codes_id']}');
          log('[services/phone_code_create_service.dart][createPhoneCodeByUser] Confirm code: ${payload['confirm_code']}');
          return true;
        } else {
          log('❌ Phone code creation failed with status code: $statusCode');
          return false;
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in createPhoneCodeByUser: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Alternative method that returns the full response data for more detailed information.
  Future<PhoneCodeCreateResponse?> createPhoneCodeByUserDetailed({
    required String inputContactId,
  }) async {
    log('[services/phone_code_create_service.dart][createPhoneCodeByUserDetailed] Calling RPC for phone_codes_create_by_user');
    log('[services/phone_code_create_service.dart][createPhoneCodeByUserDetailed] Contact ID: $inputContactId');

    try {
      final response = await _client.rpc('phone_codes_create_by_user', params: {
        'input_contact_id': inputContactId,
      });

      log('[services/phone_code_create_service.dart][createPhoneCodeByUserDetailed] Received response: $response');

      if (response == null) {
        log('❌ No response from phone_codes_create_by_user');
        return null;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        return PhoneCodeCreateResponse.fromJson(response.first as Map<String, dynamic>);
      } else {
        // Handle case where response is not a list (single item)
        return PhoneCodeCreateResponse.fromJson(response as Map<String, dynamic>);
      }
    } catch (e, stackTrace) {
      log('❌ Error in createPhoneCodeByUserDetailed: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2025-01-16 17:30:00
