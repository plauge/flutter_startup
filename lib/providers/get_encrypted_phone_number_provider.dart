import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../services/get_encrypted_phone_number_service.dart';

part 'generated/get_encrypted_phone_number_provider.g.dart';

@riverpod
GetEncryptedPhoneNumberService getEncryptedPhoneNumberService(Ref ref) {
  return GetEncryptedPhoneNumberService(Supabase.instance.client);
}

// Simple function that ALWAYS fetches fresh data - no caching
@Riverpod(keepAlive: false)
Future<String?> getEncryptedPhoneNumber(Ref ref) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] ALWAYS fetching fresh encrypted phone number data - NO CACHE');

  try {
    final service = ref.read(getEncryptedPhoneNumberServiceProvider);
    final result = await service.getEncryptedPhoneNumber();

    log('[providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] Successfully retrieved encrypted phone number data');

    if (result != null) {
      log('[providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] Encrypted phone number retrieved successfully');
    } else {
      log('[providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] No encrypted phone number found');
    }

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] Error: $error');
    log('❌ [providers/get_encrypted_phone_number_provider.dart][getEncryptedPhoneNumber] Stack trace: $stackTrace');
    rethrow;
  }
}

// File created: 2025-01-06 15:45:00
