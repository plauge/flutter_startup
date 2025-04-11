import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class AuthDeleteService {
  final SupabaseClient _client;
  final _logger = Logger('AuthDeleteService');

  AuthDeleteService(this._client);

  Future<bool> deleteUser() async {
    try {
      _logger.info('Attempting to delete user');
      final response = await _client.rpc('auth_delete_user');

      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0]['data'];
        final success = data['success'] as bool;
        _logger.info('User deletion completed. Success: $success');
        return success;
      }
      _logger.warning('Unexpected response format from delete user');
      return false;
    } on PostgrestException catch (error) {
      _logger.severe('Database error during user deletion', error);
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      _logger.severe('Failed to delete user', error);
      throw Exception('Failed to delete user: $error');
    }
  }
}
