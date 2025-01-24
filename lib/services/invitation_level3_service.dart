import 'package:flutter_startup/exports.dart';

class InvitationLevel3Service {
  final SupabaseClient _client;

  InvitationLevel3Service(this._client);

  Future<String> createInvitation({
    required String initiatorEncryptedKey,
    required String receiverEncryptedKey,
    required String receiverTempName,
  }) async {
    try {
      final response = await _client.rpc(
        'invitation_level_3_create',
        params: {
          'input_initiator_encrypted_key': initiatorEncryptedKey,
          'input_receiver_encrypted_key': receiverEncryptedKey,
          'input_reciever_temp_name': receiverTempName,
        },
      );

      print('Raw API Response: $response');
      print('Response Type: ${response.runtimeType}');

      if (response == null) {
        throw Exception('No response from server');
      }

      if (response is List) {
        print('Response is a List. First item: ${response.firstOrNull}');
        if (response.isNotEmpty && response.first is Map<String, dynamic>) {
          final firstItem = response.first as Map<String, dynamic>;
          print('First item data: $firstItem');

          if (firstItem['data'] != null &&
              firstItem['data'] is Map<String, dynamic>) {
            final data = firstItem['data'] as Map<String, dynamic>;
            print('Extracted data: $data');

            if (data['success'] == true && data['payload'] != null) {
              final invitationId =
                  data['payload']['invitation_level_3_id'] as String;
              return invitationId;
            }
          }
        }
        throw Exception('Invalid response format from server: $response');
      }

      final data = response as Map<String, dynamic>;
      print('Response as Map: $data');

      if (data['success'] == true && data['payload'] != null) {
        final invitationId = data['payload']['invitation_level_3_id'] as String;
        return invitationId;
      } else {
        throw Exception(data['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Exception details: $e');
      throw Exception('Failed to create invitation: $e');
    }
  }
}
