import '../exports.dart';
import 'logged_supabase_client.dart';

class PhoneCodesService {
  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient
  static final log = scopedLogger(LogCategory.service);

  PhoneCodesService(this._client);

  Future<List<PhoneCodesGetLogResponse>> getPhoneCodesLog() async {
    log('getPhoneCodesLog: Calling phone_codes_get_log RPC endpoint from lib/services/phone_codes_service.dart');

    try {
      final response = await _client.rpc('phone_codes_get_log');

      log('getPhoneCodesLog: Received response from API');

      if (response is List) {
        return response.map((item) => PhoneCodesGetLogResponse.fromJson(item)).toList();
      } else {
        // Handle case where response is not a list (single item)
        return [PhoneCodesGetLogResponse.fromJson(response)];
      }
    } catch (e, stackTrace) {
      log('getPhoneCodesLog: Error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> markPhoneCodeAsRead(String phoneCodesId, {String? inputEncryptedPhoneNumber}) async {
    log('markPhoneCodeAsRead: Calling phone_codes_receiver_read RPC endpoint from lib/services/phone_codes_service.dart');
    log('markPhoneCodeAsRead: Phone codes ID: $phoneCodesId');
    log('markPhoneCodeAsRead: Input encrypted phone number: $inputEncryptedPhoneNumber');

    try {
      final response = await _client.rpc('phone_codes_receiver_read', params: {
        'input_phone_codes_id': phoneCodesId,
        'input_encrypted_phone_number': inputEncryptedPhoneNumber,
      });

      log('markPhoneCodeAsRead: Successfully marked phone code as read');
      log('markPhoneCodeAsRead: Response: $response');
    } catch (e, stackTrace) {
      log('markPhoneCodeAsRead: Error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> markPhoneCodeAsRejected(String phoneCodesId) async {
    log('markPhoneCodeAsRejected: Calling phone_codes_receiver_rejected RPC endpoint from lib/services/phone_codes_service.dart');
    log('markPhoneCodeAsRejected: Phone codes ID: $phoneCodesId');

    try {
      final response = await _client.rpc('phone_codes_receiver_rejected', params: {
        'input_phone_codes_id': phoneCodesId,
      });

      log('markPhoneCodeAsRejected: Successfully marked phone code as rejected');
      log('markPhoneCodeAsRejected: Response: $response');
    } catch (e, stackTrace) {
      log('markPhoneCodeAsRejected: Error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> cancelPhoneCode(String inputPhoneCodesId) async {
    log('cancelPhoneCode: Calling phone_codes_initiator_cancel RPC endpoint from lib/services/phone_codes_service.dart');
    log('cancelPhoneCode: Phone codes ID: $inputPhoneCodesId');

    try {
      final response = await _client.rpc('phone_codes_initiator_cancel', params: {
        'input_phone_codes_id': inputPhoneCodesId,
      });

      log('cancelPhoneCode: Successfully cancelled phone code');
      log('cancelPhoneCode: Response: $response');
    } catch (e, stackTrace) {
      log('cancelPhoneCode: Error: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> timeoutPhoneCode(String inputPhoneCodesId) async {
    log('timeoutPhoneCode: Calling phone_codes_receiver_timeout RPC endpoint from lib/services/phone_codes_service.dart');
    log('timeoutPhoneCode: Phone codes ID: $inputPhoneCodesId');

    try {
      final response = await _client.rpc('phone_codes_receiver_timeout', params: {
        'input_phone_codes_id': inputPhoneCodesId,
      });

      log('timeoutPhoneCode: Successfully timed out phone code');
      log('timeoutPhoneCode: Response: $response');
    } catch (e, stackTrace) {
      log('timeoutPhoneCode: Error: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2025-01-16 14:32:00
