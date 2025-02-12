import 'package:id_truster/exports.dart';
import 'package:id_truster/services/auth_validation_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/auth_validation_provider.g.dart';

@riverpod
class AuthValidation extends _$AuthValidation {
  @override
  FutureOr<AuthValidationResponse> build() async {
    final client = ref.watch(supabaseClientProvider);
    final service = AuthValidationService(client);
    return service.validateSession();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
