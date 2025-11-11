import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_numbers_provider.g.dart';

@riverpod
PhoneNumbersService phoneNumbersService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return PhoneNumbersService(supabaseService.client);
}

// Simple function that ALWAYS fetches fresh data - no caching
@Riverpod(keepAlive: false)
Future<List<PhoneNumbersResponse>> phoneNumbers(Ref ref) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/phone_numbers_provider.dart][phoneNumbers] ALWAYS fetching fresh phone numbers data - NO CACHE');

  try {
    final phoneNumbersService = ref.read(phoneNumbersServiceProvider);
    final results = await phoneNumbersService.getUsersPhoneNumbers();

    log('[providers/phone_numbers_provider.dart][phoneNumbers] Successfully retrieved phone numbers data');
    log('[providers/phone_numbers_provider.dart][phoneNumbers] Number of responses: ${results.length}');
    
    if (results.isNotEmpty) {
      log('[providers/phone_numbers_provider.dart][phoneNumbers] First response status code: ${results.first.statusCode}');
      log('[providers/phone_numbers_provider.dart][phoneNumbers] First response success: ${results.first.data.success}');
      log('[providers/phone_numbers_provider.dart][phoneNumbers] First response message: ${results.first.data.message}');
      log('[providers/phone_numbers_provider.dart][phoneNumbers] Number of phone numbers: ${results.first.data.payload.length}');
    }

    return results;
  } catch (error, stackTrace) {
    log('❌ [providers/phone_numbers_provider.dart][phoneNumbers] Error: $error');
    log('❌ [providers/phone_numbers_provider.dart][phoneNumbers] Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2024-12-30 14:40:00
