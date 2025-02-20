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

  Future<Map<String, dynamic>> readInvitation(String invitationId) async {
    try {
      debugPrint('🔍 Calling invitation_level_1_read with ID: $invitationId');
      final response = await _client.rpc(
        'invitation_level_1_read',
        params: {
          'input_invitation_level_1_id': invitationId,
        },
      );

      debugPrint('📥 Raw API Response: $response');
      debugPrint('📦 Response Type: ${response.runtimeType}');

      if (response == null) {
        debugPrint('❌ Response is null');
        throw Exception('No response from server');
      }

      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        debugPrint('📋 First item from list: $firstItem');

        // Check status code
        final statusCode = firstItem['status_code'] as int?;
        if (statusCode != 200) {
          debugPrint('❌ Invalid status code: $statusCode');
          throw Exception('Server returned status code: $statusCode');
        }

        final data = firstItem['data'] as Map<String, dynamic>?;
        if (data == null) {
          debugPrint('❌ No data field in response');
          throw Exception('No data field in response');
        }

        debugPrint('📄 Data content: $data');

        final success = data['success'] as bool?;
        if (success != true) {
          debugPrint('❌ Operation not successful');
          throw Exception(data['message'] ?? 'Operation not successful');
        }

        final payload = data['payload'] as Map<String, dynamic>?;
        if (payload == null) {
          debugPrint('❌ No payload in response');
          throw Exception('No payload in response');
        }

        debugPrint('✅ Successfully extracted payload: $payload');
        return data; // Return entire data object instead of just payload
      }

      debugPrint('❌ Invalid response format');
      throw Exception('Invalid response format from server');
    } catch (e) {
      debugPrint('❌ Exception caught: $e');
      debugPrint('🔍 Stack trace: ${StackTrace.current}');
      throw Exception('Failed to read invitation: $e');
    }
  }

  Future<void> deleteInvitation(String invitationId) async {
    debugPrint('Attempting to delete invitation with ID: $invitationId');
    try {
      final response = await _client.rpc('invitation_level_1_delete', params: {
        'input_invitation_level_1_id': invitationId,
      });
      debugPrint('API Response: $response');
      debugPrint('Successfully deleted invitation with ID: $invitationId');
    } on PostgrestException catch (e) {
      debugPrint('Error deleting invitation: ${e.message}');
      throw Exception('Failed to delete invitation: ${e.message}');
    }
  }

  Future<void> confirmInvitation(String invitationId) async {
    debugPrint('Attempting to confirm invitation with ID: $invitationId');
    try {
      final response = await _client.rpc('invitation_level_1_confirm', params: {
        'input_invitation_level_1_id': invitationId,
      });
      debugPrint('API Response: $response');
      debugPrint('Successfully confirmed invitation with ID: $invitationId');
    } on PostgrestException catch (e) {
      debugPrint('Error confirming invitation: ${e.message}');
      throw Exception('Failed to confirm invitation: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> waitingForInitiator() async {
    debugPrint('Calling invitation_level_1_waiting_for_initiator');
    try {
      final response =
          await _client.rpc('invitation_level_1_waiting_for_initiator');
      debugPrint('API Response: $response');
      debugPrint('Successfully checked waiting invitations');

      if (response == null) {
        return [];
      }

      if (response is List) {
        if (response.isEmpty) {
          return [];
        }
        final firstItem = response[0] as Map<String, dynamic>;
        if (firstItem['data'] != null &&
            firstItem['data'] is Map<String, dynamic>) {
          final data = firstItem['data'] as Map<String, dynamic>;
          if (data['success'] == true && data['payload'] != null) {
            return (data['payload'] as List).cast<Map<String, dynamic>>();
          }
        }
        return [];
      }

      final data = response as Map<String, dynamic>;
      if (data['success'] == true && data['payload'] != null) {
        return (data['payload'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on PostgrestException catch (e) {
      debugPrint('Error checking waiting invitations: ${e.message}');
      throw Exception('Failed to check waiting invitations: ${e.message}');
    }
  }
}
