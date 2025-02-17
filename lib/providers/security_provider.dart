import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../services/security_service.dart';
import 'supabase_provider.dart';

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
  @override
  FutureOr<bool> build() => false;

  /// Verifies a pincode and updates the state accordingly
  Future<bool> verifyPincode(String pincode) async {
    debugPrint('Verifying pincode: $pincode');
    try {
      final service = ref.read(securityServiceProvider);
      final result = await service.verifyPincode(pincode);
      debugPrint('Pincode verification result: $result');
      state = AsyncData(result);
      return result;
    } on Exception catch (e, st) {
      debugPrint('Error during pincode verification: $e');
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
      debugPrint('Failed to perform caretaking: $e');
      rethrow;
    }
  }
}
