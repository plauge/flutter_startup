import 'package:idtruster/exports.dart';

class InvitationPendingService {
  final SupabaseClient _client;

  InvitationPendingService(this._client);

  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    debugPrint('Calling invitation_pending');
    try {
      final response = await _client.rpc('invitation_pending');
      debugPrint('API Response: $response');
      debugPrint('Successfully checked pending invitations');

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
      debugPrint('Error checking pending invitations: ${e.message}');
      throw Exception('Failed to check pending invitations: ${e.message}');
    }
  }
}
