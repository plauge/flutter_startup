import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class SecurityPinCodeService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  SecurityPinCodeService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// Sends a temporary PIN code to the user via email
  ///
  /// Returns the status code from the response
  Future<int> sendTemporaryPinCode() async {
    try {
      log('SecurityPinCodeService.sendTemporaryPinCode - Starting request');

      final response = await _client.rpc('security_send_user_temporary_pin_code');

      log('SecurityPinCodeService.sendTemporaryPinCode - Response received: ${response.toString()}');

      if (response == null || response.isEmpty) {
        throw Exception('Empty response from server');
      }

      // Since the response is a list with one element, we take the first element
      final responseData = response[0] as Map<String, dynamic>;

      final statusCode = responseData['status_code'] as int;

      log('SecurityPinCodeService.sendTemporaryPinCode - Success with status code: $statusCode');

      return statusCode;
    } catch (e) {
      log('SecurityPinCodeService.sendTemporaryPinCode - Error: $e');
      rethrow;
    }
  }
}

// Created: 2024-12-19 17:00:00
