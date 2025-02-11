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

  Future<Map<String, dynamic>> watch({
    required String confirmsId,
  }) async {
    try {
      final response = await _client.rpc(
        'confirms_watch',
        params: {
          'input_confirms_id': confirmsId,
        },
      );
      debugPrint('Successfully watched confirm: $response');
      final List<dynamic> list = response as List<dynamic>;
      return list.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error watching confirm: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmsRecieverUpdate({
    required String answer,
    required String confirmsId,
  }) async {
    try {
      debugPrint('🔷 ConfirmsService - Calling confirms_reciever_update');
      final response = await _client.rpc(
        'confirms_reciever_update',
        params: {
          'input_answer': answer,
          'input_confirms_id': confirmsId,
        },
      );
      debugPrint('🔷 ConfirmsService - Raw response: $response');
      final List<dynamic> list = response as List<dynamic>;
      final result = list.first as Map<String, dynamic>;
      debugPrint('🔷 ConfirmsService - Processed response: $result');
      return result;
    } catch (e) {
      debugPrint('❌ ConfirmsService - Error in confirmsRecieverUpdate: $e');
      rethrow;
    }
  }
}
