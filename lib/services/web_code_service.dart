import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/web_code_receive_response.dart';
import '../exports.dart';

class WebCodeService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  WebCodeService(this._client);

  Future<List<WebCodeReceiveResponse>> receiveWebCode({
    required String webCodesId,
  }) async {
    log('receiveWebCode: Calling API with webCodesId: $webCodesId');

    try {
      final response = await _client.rpc(
        'receive_web_code',
        params: {
          'input_web_codes_id': webCodesId,
        },
      );

      log('receiveWebCode: Received response from API');

      if (response is List) {
        return response.map((item) => WebCodeReceiveResponse.fromJson(item)).toList();
      } else {
        // Handle case where response is not a list (single item)
        return [WebCodeReceiveResponse.fromJson(response)];
      }
    } catch (e, stackTrace) {
      log('receiveWebCode: Error: $e\n$stackTrace');
      rethrow;
    }
  }
}

// Created: 2023-08-08 15:35:00
