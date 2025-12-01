import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../services/security_set_securekey_is_saved_service.dart';

part 'generated/security_set_securekey_is_saved_provider.g.dart';

@riverpod
SecuritySetSecurekeyIsSavedService securitySetSecurekeyIsSavedService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return SecuritySetSecurekeyIsSavedService(supabaseService.client);
}

/// Provider that calls the security_set_securekey_is_saved RPC endpoint.
/// This marks that the secure key has been saved.
@Riverpod(keepAlive: false)
Future<void> securitySetSecurekeyIsSaved(Ref ref) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/security_set_securekey_is_saved_provider.dart][securitySetSecurekeyIsSaved] Calling security_set_securekey_is_saved');

  try {
    final service = ref.read(securitySetSecurekeyIsSavedServiceProvider);
    await service.setSecurekeyIsSaved();

    log('[providers/security_set_securekey_is_saved_provider.dart][securitySetSecurekeyIsSaved] ✅ Successfully called security_set_securekey_is_saved');
  } catch (error, stackTrace) {
    log('❌ [providers/security_set_securekey_is_saved_provider.dart][securitySetSecurekeyIsSaved] Error: $error');
    log('❌ [providers/security_set_securekey_is_saved_provider.dart][securitySetSecurekeyIsSaved] Stack trace: $stackTrace');
    rethrow;
  }
}

// File created: 2025-01-09 12:00:00

