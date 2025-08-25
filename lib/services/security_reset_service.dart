import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class SecurityResetService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  SecurityResetService(this._client);

  /// Resets the security token data for the current user
  /// Returns true if the operation was successful (status_code 200)
  Future<bool> resetSecurityTokenData() async {
    try {
      log('SecurityResetService.resetSecurityTokenData() - Starting security token reset');

      final response = await _client.rpc('security_reset_security_token_data');
      log('SecurityResetService.resetSecurityTokenData() - API call completed', {'response': response});

      if (response != null && response is List && response.isNotEmpty) {
        final data = response[0];
        final statusCode = data['status_code'] as int?;
        log('SecurityResetService.resetSecurityTokenData() - Response parsed', {'statusCode': statusCode});

        final success = statusCode == 200;
        log('SecurityResetService.resetSecurityTokenData() - Operation result', {'success': success, 'statusCode': statusCode});
        return success;
      }

      log('SecurityResetService.resetSecurityTokenData() - Unexpected response format');
      return false;
    } on PostgrestException catch (error) {
      log('SecurityResetService.resetSecurityTokenData() - Database error', {'error': error.message, 'code': error.code});
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      log('SecurityResetService.resetSecurityTokenData() - Unexpected error', {'error': error.toString(), 'errorType': error.runtimeType.toString()});
      throw Exception('Failed to reset security token data: $error');
    }
  }
}

// Created on: 2024-12-19 16:45
