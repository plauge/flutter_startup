import '../exports.dart';
import 'logged_supabase_client.dart';

class TextCodesService {
  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient
  static final log = scopedLogger(LogCategory.service);

  TextCodesService(this._client);

  Future<List<TextCodesReadResponse>> readTextCodeByConfirmCode(String confirmCode) async {
    log('readTextCodeByConfirmCode: Calling text_codes_read_by_confirm_code RPC endpoint from lib/services/text_codes_service.dart');
    log('readTextCodeByConfirmCode: Confirm code: $confirmCode');

    try {
      final response = await _client.rpc('text_codes_read_by_confirm_code', params: {
        'input_confirm_code': confirmCode,
      });

      log('readTextCodeByConfirmCode: Received response from API');

      if (response is List) {
        return response.map((item) => TextCodesReadResponse.fromJson(item)).toList();
      } else {
        // Handle case where response is not a list (single item)
        return [TextCodesReadResponse.fromJson(response)];
      }
    } catch (e, stackTrace) {
      log('readTextCodeByConfirmCode: Error: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2025-01-27 18:31:00
