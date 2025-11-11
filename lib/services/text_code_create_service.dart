import '../exports.dart';
import 'logged_supabase_client.dart';

class TextCodeCreateService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  TextCodeCreateService(this._client);

  /// Calls the text_codes_create_by_user RPC and returns true if successful (status_code 200).
  Future<bool> createTextCodeByUser({
    required String inputContactId,
  }) async {
    log('[services/text_code_create_service.dart][createTextCodeByUser] Calling RPC for text_codes_create_by_user');
    log('[services/text_code_create_service.dart][createTextCodeByUser] Contact ID: $inputContactId');

    try {
      final response = await _client.rpc('text_codes_create_by_user', params: {
        'input_contact_id': inputContactId,
      });

      log('[services/text_code_create_service.dart][createTextCodeByUser] Received response: $response');

      if (response == null) {
        log('❌ No response from text_codes_create_by_user');
        return false;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int;

        log('[services/text_code_create_service.dart][createTextCodeByUser] Status code: $statusCode');

        if (statusCode == 200) {
          final data = firstItem['data'] as Map<String, dynamic>;
          final payload = data['payload'] as Map<String, dynamic>;
          log('✅ Text code created successfully');
          log('[services/text_code_create_service.dart][createTextCodeByUser] Text codes ID: ${payload['text_codes_id']}');
          log('[services/text_code_create_service.dart][createTextCodeByUser] Confirm code: ${payload['confirm_code']}');
          return true;
        } else {
          log('❌ Text code creation failed with status code: $statusCode');
          return false;
        }
      } else {
        // Handle case where response is not a list (single item)
        final statusCode = response['status_code'] as int;

        log('[services/text_code_create_service.dart][createTextCodeByUser] Status code: $statusCode');

        if (statusCode == 200) {
          final data = response['data'] as Map<String, dynamic>;
          final payload = data['payload'] as Map<String, dynamic>;
          log('✅ Text code created successfully');
          log('[services/text_code_create_service.dart][createTextCodeByUser] Text codes ID: ${payload['text_codes_id']}');
          log('[services/text_code_create_service.dart][createTextCodeByUser] Confirm code: ${payload['confirm_code']}');
          return true;
        } else {
          log('❌ Text code creation failed with status code: $statusCode');
          return false;
        }
      }
    } catch (e, stackTrace) {
      log('❌ Error in createTextCodeByUser: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Alternative method that returns the full response data for more detailed information.
  Future<TextCodeCreateResponse?> createTextCodeByUserDetailed({
    required String inputContactId,
  }) async {
    log('[services/text_code_create_service.dart][createTextCodeByUserDetailed] Calling RPC for text_codes_create_by_user');
    log('[services/text_code_create_service.dart][createTextCodeByUserDetailed] Contact ID: $inputContactId');

    try {
      final response = await _client.rpc('text_codes_create_by_user', params: {
        'input_contact_id': inputContactId,
      });

      log('[services/text_code_create_service.dart][createTextCodeByUserDetailed: Received response: $response');

      if (response == null) {
        log('❌ No response from text_codes_create_by_user');
        return null;
      }

      // Response kommer som en liste, så vi tager første element
      if (response is List && response.isNotEmpty) {
        return TextCodeCreateResponse.fromJson(response.first as Map<String, dynamic>);
      } else {
        // Handle case where response is not a list (single item)
        return TextCodeCreateResponse.fromJson(response as Map<String, dynamic>);
      }
    } catch (e, stackTrace) {
      log('❌ Error in createTextCodeByUserDetailed: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2025-01-16 18:30:00
