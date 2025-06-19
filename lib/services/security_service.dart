import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../exports.dart';

class SecurityService {
  final SupabaseClient _client;
  final _logger = Logger('SecurityService');
  static final log = scopedLogger(LogCategory.service);

  SecurityService(this._client);

  Future<bool> verifyPincode(String pincode) async {
    try {
      _logger.info('Attempting to verify pincode');
      final response = await _client.rpc('security_verify_pincode', params: {'input_pincode': pincode});

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

  Future<List<dynamic>> doCaretaking(String appVersion) async {
    try {
      _logger.info('Starting security caretaking check for app version: $appVersion');
      final response = await _client.rpc(
        'security_do_caretaking',
        params: {'input_app_version': appVersion},
      );
      _logger.info('Security caretaking completed successfully');
      return response as List<dynamic>;
    } on PostgrestException catch (error) {
      _logger.severe('Database error during caretaking', error);
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      _logger.severe('Failed to perform security caretaking', error);
      throw Exception('Failed to perform security caretaking: $error');
    }
  }

  Future<bool> resetLoadTime() async {
    try {
      _logger.info('Attempting to reset load time');
      final response = await _client.rpc('security_reset_load_time');

      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0]['data'];
        final success = data['success'] as bool;
        _logger.info('Load time reset completed. Success: $success');
        return success;
      }
      _logger.warning('Unexpected response format from reset load time');
      return false;
    } on PostgrestException catch (error) {
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      _logger.severe('Failed to reset load time', error);
      throw Exception('Failed to reset load time: $error');
    }
  }

  Future<bool> updateUserExtraLatestLoad() async {
    try {
      log('updateUserExtraLatestLoad: Calling security_update_user_extra_latest_load RPC endpoint from lib/services/security_service.dart');
      final response = await _client.rpc('security_update_user_extra_latest_load');

      log('updateUserExtraLatestLoad: Received response from API: $response');

      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0]['data'];
        final success = data['success'] as bool;
        log('updateUserExtraLatestLoad: Operation completed. Success: $success');
        return success;
      }
      log('updateUserExtraLatestLoad: Unexpected response format');
      return false;
    } on PostgrestException catch (error) {
      log('updateUserExtraLatestLoad: Database error: ${error.message}');
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      log('updateUserExtraLatestLoad: Failed to update user extra latest load: $error');
      throw Exception('Failed to update user extra latest load: $error');
    }
  }
}
