import '../exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/security_pin_code_update_service.dart';
import '../utils/app_logger.dart';

part 'generated/security_pin_code_update_provider.g.dart';

@riverpod
class SecurityPinCodeUpdate extends _$SecurityPinCodeUpdate {
  static final log = scopedLogger(LogCategory.provider);

  @override
  FutureOr<int?> build() {
    log('Initializing SecurityPinCodeUpdate provider - lib/providers/security_pin_code_update_provider.dart:build()');
    return null;
  }

  Future<bool> updatePinCode({
    required String newPinCode,
    required String temporaryPinCode,
  }) async {
    log('Starting PIN code update process - lib/providers/security_pin_code_update_provider.dart:updatePinCode()');

    state = const AsyncValue.loading();

    try {
      final statusCode = await SecurityPinCodeUpdateService.updatePinCode(
        newPinCode: newPinCode,
        temporaryPinCode: temporaryPinCode,
      );

      state = AsyncValue.data(statusCode);

      final success = statusCode == 200;
      log('PIN code update completed with status: $statusCode, success: $success - lib/providers/security_pin_code_update_provider.dart:updatePinCode()');

      return success;
    } catch (e, stackTrace) {
      log('PIN code update provider error: $e - lib/providers/security_pin_code_update_provider.dart:updatePinCode()');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  void reset() {
    log('Resetting SecurityPinCodeUpdate provider state - lib/providers/security_pin_code_update_provider.dart:reset()');
    state = const AsyncValue.data(null);
  }
}

// Created: 2024-12-13 15:45:00
