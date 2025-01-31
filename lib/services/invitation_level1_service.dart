import 'package:flutter_startup/exports.dart';

class InvitationLevel1Service {
  final SupabaseClient _client;
  InvitationLevel1Service(this._client);

  Future<String> createInvitation({
    required String initiatorEncryptedKey,
    required String receiverEncryptedKey,
    required String receiverTempName,
  }) async {
    final response = await _client.rpc(
      'invitation_level_1_create',
      params: {
        'input_initiator_encrypted_key': initiatorEncryptedKey,
        'input_receiver_encrypted_key': receiverEncryptedKey,
        'input_reciever_temp_name': receiverTempName,
      },
    );
    return response as String;
  }
}
