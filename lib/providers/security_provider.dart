import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../services/security_service.dart';
import 'supabase_provider.dart';
import '../exports.dart';

part 'generated/security_provider.g.dart';

/// Provides an instance of SecurityService
@Riverpod(keepAlive: true)
SecurityService securityService(SecurityServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SecurityService(supabase);
}

/// Handles pincode verification state and operations
@riverpod
class SecurityVerification extends _$SecurityVerification {
  static final log = scopedLogger(LogCategory.provider);
  @override
  FutureOr<bool> build() => false;

  /// Verifies a pincode and updates the state accordingly
  Future<bool> verifyPincode(String pincode) async {
    log('Verifying pincode: $pincode');
    try {
      final service = ref.read(securityServiceProvider);
      final result = await service.verifyPincode(pincode);
      log('Pincode verification result: $result');
      state = AsyncData(result);
      return result;
    } on Exception catch (e, st) {
      log('Error during pincode verification: $e');
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Performs security caretaking check
  Future<List<dynamic>> doCaretaking(String appVersion) async {
    try {
      final service = ref.read(securityServiceProvider);
      final result = await service.doCaretaking(appVersion);
      return result;
    } on Exception catch (e, st) {
      log('Failed to perform caretaking: $e');
      rethrow;
    }
  }

  /// Resets the load time and updates the state accordingly
  Future<bool> resetLoadTime() async {
    log('Resetting load time');
    try {
      final service = ref.read(securityServiceProvider);
      final result = await service.resetLoadTime();
      log('Load time reset result: $result');
      state = AsyncData(result);
      return result;
    } on Exception catch (e, st) {
      log('Error during load time reset: $e');
      state = AsyncError(e, st);
      return false;
    }
  }
}
