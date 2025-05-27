import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import '../services/auth_delete_service.dart';
import 'supabase_provider.dart';
import '../exports.dart';

part 'generated/auth_delete_provider.g.dart';

/// Provides an instance of AuthDeleteService
@Riverpod(keepAlive: true)
AuthDeleteService authDeleteService(AuthDeleteServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthDeleteService(supabase);
}

/// Handles user deletion state and operations
@riverpod
class AuthDelete extends _$AuthDelete {
  static final log = scopedLogger(LogCategory.provider);
  @override
  FutureOr<bool> build() => false;

  /// Deletes the current user and updates the state accordingly
  Future<bool> deleteUser() async {
    try {
      final service = ref.read(authDeleteServiceProvider);
      final result = await service.deleteUser();
      state = AsyncData(result);
      return result;
    } on Exception catch (e, st) {
      //debugPrint('Error during user deletion: $e');
      state = AsyncError(e, st);
      return false;
    }
  }
}
