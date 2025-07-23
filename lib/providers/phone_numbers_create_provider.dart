import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_numbers_create_provider.g.dart';

@riverpod
PhoneNumbersCreateService phoneNumbersCreateService(Ref ref) {
  return PhoneNumbersCreateService(Supabase.instance.client);
}

@riverpod
Future<bool> createPhoneNumber(
  Ref ref, {
  required String inputEncryptedPhoneNumber,
  required String inputPhoneNumber,
  required String inputPinCode,
}) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/phone_numbers_create_provider.dart][createPhoneNumber] Processing phone number creation request');
  log('[providers/phone_numbers_create_provider.dart][createPhoneNumber] Encrypted phone number length: ${inputEncryptedPhoneNumber.length}');
  log('[providers/phone_numbers_create_provider.dart][createPhoneNumber] Plain phone number: $inputPhoneNumber');
  log('[providers/phone_numbers_create_provider.dart][createPhoneNumber] PIN code: $inputPinCode');

  try {
    final phoneNumbersCreateService = ref.watch(phoneNumbersCreateServiceProvider);
    final result = await phoneNumbersCreateService.createPhoneNumber(
      inputEncryptedPhoneNumber: inputEncryptedPhoneNumber,
      inputPhoneNumber: inputPhoneNumber,
      inputPinCode: inputPinCode,
    );

    log('[providers/phone_numbers_create_provider.dart][createPhoneNumber] Phone number creation result: $result');

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/phone_numbers_create_provider.dart][createPhoneNumber] Error: $error');
    log('❌ [providers/phone_numbers_create_provider.dart][createPhoneNumber] Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2024-12-30 20:30:00
