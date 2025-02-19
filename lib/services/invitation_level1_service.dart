import 'package:idtruster/exports.dart';

class InvitationLevel1Service {
  final SupabaseClient _client;
  InvitationLevel1Service(this._client) {
    debugPrint('InvitationLevel1Service initialized');
  }

  Future<Map<String, dynamic>> createInvitation({
    required String initiatorEncryptedKey,
    required String receiverEncryptedKey,
    required String receiverTempName,
  }) async {
    debugPrint(
        'Calling invitation_level_1_create RPC for receiver: $receiverTempName');
    try {
      final response = await _client.rpc(
        'invitation_level_1_create',
        params: {
          'input_initiator_encrypted_key': initiatorEncryptedKey,
          'input_receiver_encrypted_key': receiverEncryptedKey,
          'input_reciever_temp_name': receiverTempName,
        },
      );
      debugPrint('Successfully created Level 1 invitation: $response');
      final List<dynamic> list = response as List<dynamic>;
      return list.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating Level 1 invitation: $e');
      rethrow;
    }
  }
}
