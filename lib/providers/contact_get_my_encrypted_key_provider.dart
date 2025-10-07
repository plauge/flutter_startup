import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../services/contact_get_my_encrypted_key_service.dart';

part 'generated/contact_get_my_encrypted_key_provider.g.dart';

@riverpod
ContactGetMyEncryptedKeyService contactGetMyEncryptedKeyService(Ref ref) {
  return ContactGetMyEncryptedKeyService(Supabase.instance.client);
}

// Simple function that ALWAYS fetches fresh data - no caching
@Riverpod(keepAlive: false)
Future<String?> contactGetMyEncryptedKey(Ref ref, String inputMyContactUserId) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] ALWAYS fetching fresh encrypted key for contact user: $inputMyContactUserId - NO CACHE');

  try {
    final service = ref.read(contactGetMyEncryptedKeyServiceProvider);
    final result = await service.getMyEncryptedKeyForContact(inputMyContactUserId);

    log('[providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] Successfully retrieved encrypted key');

    if (result != null) {
      log('[providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] Encrypted key retrieved successfully');
    } else {
      log('[providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] No encrypted key found');
    }

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] Error: $error');
    log('❌ [providers/contact_get_my_encrypted_key_provider.dart][contactGetMyEncryptedKey] Stack trace: $stackTrace');
    rethrow;
  }
}

// File created: 2025-10-07 14:30:00
