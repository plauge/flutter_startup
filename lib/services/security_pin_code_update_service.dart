import '../exports.dart';
import '../utils/app_logger.dart';

class SecurityPinCodeUpdateService {
  static final log = scopedLogger(LogCategory.service);

  static Future<int> updatePinCode({
    required String newPinCode,
    required String temporaryPinCode,
  }) async {
    log('Starting PIN code update - lib/services/security_pin_code_update_service.dart:updatePinCode()');

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.rpc('security_update_pin_code', params: {
        'input_new_pin_code': newPinCode,
        'input_temporary_pin_code': temporaryPinCode,
      });

      log('PIN code update response received - lib/services/security_pin_code_update_service.dart:updatePinCode()');

      if (response != null && response is List && response.isNotEmpty) {
        final statusCode = response[0]['status_code'] as int? ?? 500;
        log('PIN code update status code: $statusCode - lib/services/security_pin_code_update_service.dart:updatePinCode()');
        return statusCode;
      }

      log('PIN code update failed: Invalid response format - lib/services/security_pin_code_update_service.dart:updatePinCode()');
      return 500;
    } catch (e) {
      log('PIN code update error: $e - lib/services/security_pin_code_update_service.dart:updatePinCode()');
      return 500;
    }
  }
}

// Created: 2024-12-13 15:45:00
