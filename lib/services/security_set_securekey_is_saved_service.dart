import '../utils/app_logger.dart';
import '../exports.dart';

/// Service for calling the security_set_securekey_is_saved Supabase RPC endpoint.
class SecuritySetSecurekeyIsSavedService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  SecuritySetSecurekeyIsSavedService(this._client);

  /// Calls the security_set_securekey_is_saved RPC endpoint.
  /// This endpoint marks that the secure key has been saved.
  Future<void> setSecurekeyIsSaved() async {
    log('[services/security_set_securekey_is_saved_service.dart][setSecurekeyIsSaved] Calling RPC for security_set_securekey_is_saved');

    try {
      await _client.rpc('security_set_securekey_is_saved');

      log('[services/security_set_securekey_is_saved_service.dart][setSecurekeyIsSaved] ✅ Successfully called security_set_securekey_is_saved');
    } catch (e, st) {
      log('❌ [services/security_set_securekey_is_saved_service.dart][setSecurekeyIsSaved] Error: $e\n$st');
      rethrow;
    }
  }
}

// File created: 2025-01-09 12:00:00

