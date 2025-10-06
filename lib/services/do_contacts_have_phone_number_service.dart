import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

/// Service for calling the do_contacts_have_phone_number Supabase RPC endpoint.
class DoContactsHavePhoneNumberService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  DoContactsHavePhoneNumberService(this._client);

  /// Calls the do_contacts_have_phone_number RPC with the given contact ID and returns the has_phone_number boolean.
  Future<bool?> doContactsHavePhoneNumber(String inputContactId) async {
    log('[services/do_contacts_have_phone_number_service.dart][doContactsHavePhoneNumber] Calling RPC for contact ID: $inputContactId');

    try {
      final response = await _client.rpc(
        'do_contacts_have_phone_number',
        params: {'input_contact_id': inputContactId},
      );

      log('[services/do_contacts_have_phone_number_service.dart][doContactsHavePhoneNumber] Received response: $response');

      if (response == null) {
        log('❌ No response from do_contacts_have_phone_number');
        return null;
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from do_contacts_have_phone_number');
          return null;
        }
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;

        if (!data['success']) {
          log('❌ Operation not successful: ${data['message']}');
          return null;
        }

        final payload = data['payload'] as Map<String, dynamic>;
        final hasPhoneNumber = payload['has_phone_number'] as bool;
        log('✅ Successfully retrieved phone number status: $hasPhoneNumber');
        return hasPhoneNumber;
      }

      // Handle single object response
      final data = response['data'] as Map<String, dynamic>;
      if (!data['success']) {
        log('❌ Operation not successful: ${data['message']}');
        return null;
      }

      final payload = data['payload'] as Map<String, dynamic>;
      final hasPhoneNumber = payload['has_phone_number'] as bool;
      log('✅ Successfully retrieved phone number status: $hasPhoneNumber');
      return hasPhoneNumber;
    } catch (error, stackTrace) {
      log('❌ Error in doContactsHavePhoneNumber: $error\n$stackTrace');
      rethrow;
    }
  }
}

// File created: 2025-01-06 16:00:00
