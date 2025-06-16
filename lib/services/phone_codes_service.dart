import '../exports.dart';

class PhoneCodesService {
  final SupabaseClient _client;
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
}

// Created: 2025-01-16 14:32:00
