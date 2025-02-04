import 'package:flutter_startup/exports.dart';

class ConfirmsService {
  final SupabaseClient _client;

  ConfirmsService(this._client);

  Future<Map<String, dynamic>> confirmConfirm({
    required String contactsId,
    required String question,
  }) async {
    try {
      final response = await _client.rpc(
        'confirms_confirm',
        params: {
          'input_contacts_id': contactsId,
          'input_question': question,
        },
      );

      debugPrint('Raw API Response: $response');
      debugPrint('Response Type: ${response.runtimeType}');

      if (response == null) {
        throw Exception('No response from server');
      }

      if (response is List) {
        debugPrint('Response is a List. First item: ${response.firstOrNull}');
        if (response.isNotEmpty && response.first is Map<String, dynamic>) {
          final firstItem = response.first as Map<String, dynamic>;
          debugPrint('First item data: $firstItem');

          if (firstItem['status_code'] == 200 &&
              firstItem['data'] != null &&
              firstItem['data'] is Map<String, dynamic>) {
            final data = firstItem['data'] as Map<String, dynamic>;
            debugPrint('Extracted data: $data');

            if (data['success'] == true && data['payload'] != null) {
              return {
                'status_code': firstItem['status_code'],
                'question': data['payload']['question'],
                'new_record': data['payload']['new_record'],
                'confirms_id': data['payload']['confirms_id'],
              };
            }
          }
        }
        throw Exception('Invalid response format from server: $response');
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      debugPrint('Exception details: $e');
      throw Exception('Failed to create confirm: $e');
    }
  }
}
