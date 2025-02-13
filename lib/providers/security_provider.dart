import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    state = const AsyncLoading();
    try {
      final service = ref.read(securityServiceProvider);
      final result = await service.verifyPincode(pincode);
      state = AsyncData(result);
      return result;
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
