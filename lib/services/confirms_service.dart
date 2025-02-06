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
      debugPrint('Successfully created confirm: $response');
      final List<dynamic> list = response as List<dynamic>;
      return list.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating confirm: $e');
      rethrow;
    }
  }
}
