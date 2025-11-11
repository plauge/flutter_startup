import '../exports.dart';
import 'logged_supabase_client.dart';

/// Service for calling the get_users_phone_numbers Supabase RPC endpoint.
class PhoneNumbersService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  PhoneNumbersService(this._client);

  /// Calls the get_users_phone_numbers RPC and returns the phone numbers.
  Future<List<PhoneNumbersResponse>> getUsersPhoneNumbers() async {
    log('[services/phone_numbers_service.dart][getUsersPhoneNumbers] Calling RPC for get_users_phone_numbers');

    try {
      final response = await _client.rpc('get_users_phone_numbers');

      log('[services/phone_numbers_service.dart][getUsersPhoneNumbers] Received response: $response');

      if (response == null) {
        log('❌ No response from get_users_phone_numbers');
        return [];
      }

      if (response is List) {
        return response.map((item) => PhoneNumbersResponse.fromJson(item)).toList();
      } else {
        // Handle case where response is not a list (single item)
        return [PhoneNumbersResponse.fromJson(response)];
      }
    } catch (e, stackTrace) {
      log('❌ Error in getUsersPhoneNumbers: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2024-12-30 14:35:00
