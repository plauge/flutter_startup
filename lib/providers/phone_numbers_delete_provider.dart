import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_numbers_delete_provider.g.dart';

@riverpod
PhoneNumbersDeleteService phoneNumbersDeleteService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return PhoneNumbersDeleteService(supabaseService.client);
}

@riverpod
Future<bool> deletePhoneNumber(
  Ref ref, {
  required String inputPhoneNumber,
}) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/phone_numbers_delete_provider.dart][deletePhoneNumber] Processing phone number deletion request');
  log('[providers/phone_numbers_delete_provider.dart][deletePhoneNumber] Phone number: $inputPhoneNumber');

  try {
    final phoneNumbersDeleteService = ref.watch(phoneNumbersDeleteServiceProvider);
    final result = await phoneNumbersDeleteService.deletePhoneNumber(
      inputPhoneNumber: inputPhoneNumber,
    );

    log('[providers/phone_numbers_delete_provider.dart][deletePhoneNumber] Phone number deletion result: $result');

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/phone_numbers_delete_provider.dart][deletePhoneNumber] Error: $error');
    log('❌ [providers/phone_numbers_delete_provider.dart][deletePhoneNumber] Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2024-12-30 20:45:00
