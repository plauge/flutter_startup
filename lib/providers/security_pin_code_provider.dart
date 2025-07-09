import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/security_pin_code_service.dart';
import '../utils/app_logger.dart';

part 'generated/security_pin_code_provider.g.dart';

@riverpod
class SecurityPinCodeNotifier extends _$SecurityPinCodeNotifier {
  static final log = scopedLogger(LogCategory.provider);

  late final SecurityPinCodeService _service;

  @override
  FutureOr<int?> build() {
    _service = SecurityPinCodeService();
    return null;
  }

  /// Sends a temporary PIN code to the user
  ///
  /// Returns the status code from the response
  Future<int> sendTemporaryPinCode() async {
    try {
      log('SecurityPinCodeNotifier.sendTemporaryPinCode - Starting');

      state = const AsyncLoading();

      final statusCode = await _service.sendTemporaryPinCode();

      state = AsyncData(statusCode);

      log('SecurityPinCodeNotifier.sendTemporaryPinCode - Success with status code: $statusCode');

      return statusCode;
    } catch (e) {
      log('SecurityPinCodeNotifier.sendTemporaryPinCode - Error: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

// Created: 2024-12-19 17:00:00
