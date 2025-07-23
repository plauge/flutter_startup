import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/security_demo_text_code_service.dart';
import '../utils/app_logger.dart';

part 'generated/security_demo_text_code_provider.g.dart';

@riverpod
class SecurityDemoTextCodeNotifier extends _$SecurityDemoTextCodeNotifier {
  static final log = scopedLogger(LogCategory.provider);

  late final SecurityDemoTextCodeService _service;

  @override
  FutureOr<bool> build() {
    _service = SecurityDemoTextCodeService();
    return false;
  }

  /// Sends a demo text code to the user
  ///
  /// Returns true if successful (status code 200), false otherwise
  Future<bool> sendDemoTextCode() async {
    try {
      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Starting from lib/providers/security_demo_text_code_provider.dart');

      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Calling service.sendDemoTextCode()');
      final success = await _service.sendDemoTextCode();

      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Service returned: $success');
      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Completed - success: $success');

      return success;
    } catch (e, stackTrace) {
      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Exception occurred - $e');
      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Exception type: ${e.runtimeType}');
      log('SecurityDemoTextCodeNotifier.sendDemoTextCode: Stack trace: $stackTrace');

      rethrow; // Let the caller handle the exception
    }
  }
}

// File created: 2024-12-31 16:30:00
