import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_number_validation_send_pin_provider.g.dart';

@riverpod
PhoneNumberValidationSendPinService phoneNumberValidationSendPinService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return PhoneNumberValidationSendPinService(supabaseService.client);
}

@riverpod
Future<bool> sendPinForPhoneNumberValidation(
  Ref ref, {
  required String inputPhoneNumber,
}) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Processing phone number validation PIN send request');
  log('[providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Phone number: $inputPhoneNumber');

  try {
    final phoneNumberValidationSendPinService = ref.watch(phoneNumberValidationSendPinServiceProvider);
    final result = await phoneNumberValidationSendPinService.sendPinForPhoneNumberValidation(
      inputPhoneNumber: inputPhoneNumber,
    );

    log('[providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Phone number validation PIN send result: $result');

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Error: $error');
    log('❌ [providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2025-01-28 11:30:00
