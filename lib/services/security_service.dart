import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class SecurityService {
  final SupabaseClient _client;
  final _logger = Logger('SecurityService');

  SecurityService(this._client);

  Future<bool> verifyPincode(String pincode) async {
    try {
      _logger.info('Attempting to verify pincode');
      final response = await _client
          .rpc('security_verify_pincode', params: {'input_pincode': pincode});

      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0]['data'];
        final success = data['success'] as bool;
        _logger.info('Pincode verification completed. Success: $success');
        return success;
      }
      _logger.warning('Unexpected response format from verify pincode');
      return false;
    } on PostgrestException catch (error) {
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      _logger.severe('Failed to verify pincode', error);
      throw Exception('Failed to verify pincode: $error');
    }
  }
}
