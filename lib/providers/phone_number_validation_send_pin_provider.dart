import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_number_validation_send_pin_provider.g.dart';

@riverpod
PhoneNumberValidationSendPinService phoneNumberValidationSendPinService(Ref ref) {
  return PhoneNumberValidationSendPinService(Supabase.instance.client);
}

@riverpod
Future<bool> sendPinForPhoneNumberValidation(Ref ref) async {
  final log = scopedLogger(LogCategory.provider);
  log('[providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Processing phone number validation PIN send request');

  try {
    final phoneNumberValidationSendPinService = ref.watch(phoneNumberValidationSendPinServiceProvider);
    final result = await phoneNumberValidationSendPinService.sendPinForPhoneNumberValidation();

    log('[providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Phone number validation PIN send result: $result');

    return result;
  } catch (error, stackTrace) {
    log('❌ [providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Error: $error');
    log('❌ [providers/phone_number_validation_send_pin_provider.dart][sendPinForPhoneNumberValidation] Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2025-01-28 11:30:00
