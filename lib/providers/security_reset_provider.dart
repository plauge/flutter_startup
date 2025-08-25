import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/security_reset_service.dart';
import '../utils/app_logger.dart';
import 'supabase_provider.dart';

part 'generated/security_reset_provider.g.dart';

/// Provides an instance of SecurityResetService
@Riverpod(keepAlive: true)
SecurityResetService securityResetService(SecurityResetServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SecurityResetService(supabase);
}

/// Handles security reset state and operations
@riverpod
class SecurityReset extends _$SecurityReset {
  static final log = scopedLogger(LogCategory.provider);

  @override
  FutureOr<bool> build() => false;

  /// Resets the security token data for the current user
  /// Returns true if the operation was successful
  Future<bool> resetSecurityTokenData() async {
    log('SecurityReset.resetSecurityTokenData() - Starting reset operation');

    final service = ref.read(securityResetServiceProvider);
    final success = await service.resetSecurityTokenData();

    log('SecurityReset.resetSecurityTokenData() - Reset operation completed', {'success': success});
    return success;
  }
}

// Created on: 2024-12-19 16:47
