import 'package:idtruster/exports.dart';

class InvitationPendingService {
  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient
  static final log = scopedLogger(LogCategory.service);

  InvitationPendingService(this._client);

  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    log('Calling invitation_pending');
    try {
      final response = await _client.rpc('invitation_pending');
      log('API Response: $response');
      log('Successfully checked pending invitations');

      if (response == null) {
        return [];
      }

      if (response is List) {
        if (response.isEmpty) {
          return [];
        }
        final firstItem = response[0] as Map<String, dynamic>;
        if (firstItem['data'] != null && firstItem['data'] is Map<String, dynamic>) {
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
      log('Error checking pending invitations: ${e.message}');
      throw Exception('Failed to check pending invitations: ${e.message}');
    }
  }
}
