import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../services/do_contacts_have_phone_number_service.dart';

part 'generated/do_contacts_have_phone_number_provider.g.dart';

@riverpod
DoContactsHavePhoneNumberService doContactsHavePhoneNumberService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return DoContactsHavePhoneNumberService(supabaseService.client);
}

// Simple function that ALWAYS fetches fresh data - no caching
@Riverpod(keepAlive: false)
Future<bool?> doContactsHavePhoneNumber(Ref ref, String inputContactId) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] ALWAYS fetching fresh phone number status for contact: $inputContactId - NO CACHE');

  try {
    final service = ref.read(doContactsHavePhoneNumberServiceProvider);
    final result = await service.doContactsHavePhoneNumber(inputContactId);

    log('[providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] Successfully retrieved phone number status');

    if (result != null) {
      log('[providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] Contact has phone number: $result');
    } else {
      log('[providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] No phone number status found');
    }

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] Error: $error');
    log('❌ [providers/do_contacts_have_phone_number_provider.dart][doContactsHavePhoneNumber] Stack trace: $stackTrace');
    rethrow;
  }
}

// File created: 2025-01-06 16:00:00
