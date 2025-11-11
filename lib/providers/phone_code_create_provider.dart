import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_code_create_provider.g.dart';

@riverpod
PhoneCodeCreateService phoneCodeCreateService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return PhoneCodeCreateService(supabaseService.client);
}

@riverpod
class PhoneCodeCreateNotifier extends _$PhoneCodeCreateNotifier {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Creates a new phone code for the specified contact.
  /// Returns true if successful (status_code 200), false otherwise.
  Future<void> createPhoneCodeByUser(String inputContactId) async {
    state = const AsyncValue.loading();

    final log = scopedLogger(LogCategory.provider);
    log('createPhoneCodeByUser: Processing phone code creation request from lib/providers/phone_code_create_provider.dart');
    log('createPhoneCodeByUser: Contact ID: $inputContactId');

    try {
      final phoneCodeCreateService = ref.watch(phoneCodeCreateServiceProvider);
      final success = await phoneCodeCreateService.createPhoneCodeByUser(
        inputContactId: inputContactId,
      );

      if (success) {
        log('createPhoneCodeByUser: Successfully created phone code');
        state = const AsyncValue.data(true);
      } else {
        log('❌ createPhoneCodeByUser: Failed to create phone code');
        state = const AsyncValue.data(false);
      }
    } catch (error, stackTrace) {
      log('❌ createPhoneCodeByUser: Error: $error');
      log('❌ createPhoneCodeByUser: Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Creates a phone code and returns the detailed response data.
  Future<PhoneCodeCreateResponse?> createPhoneCodeDetailed(String inputContactId) async {
    final log = scopedLogger(LogCategory.provider);
    log('createPhoneCodeDetailed: Processing detailed phone code creation request from lib/providers/phone_code_create_provider.dart');
    log('createPhoneCodeDetailed: Contact ID: $inputContactId');

    try {
      final phoneCodeCreateService = ref.watch(phoneCodeCreateServiceProvider);
      final response = await phoneCodeCreateService.createPhoneCodeByUserDetailed(
        inputContactId: inputContactId,
      );

      if (response != null && response.statusCode == 200) {
        log('createPhoneCodeDetailed: Successfully created phone code');
        log('createPhoneCodeDetailed: Phone codes ID: ${response.data.payload.phoneCodesId}');
        log('createPhoneCodeDetailed: Confirm code: ${response.data.payload.confirmCode}');
      } else {
        log('❌ createPhoneCodeDetailed: Failed to create phone code or unexpected response');
      }

      return response;
    } catch (error, stackTrace) {
      log('❌ createPhoneCodeDetailed: Error: $error');
      log('❌ createPhoneCodeDetailed: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Resets the state to initial value.
  void reset() {
    state = const AsyncValue.data(false);
  }

  /// Checks if the last operation was successful.
  bool get wasSuccess => state.maybeWhen(
        data: (data) => data,
        orElse: () => false,
      );

  /// Gets any error from the last operation.
  Object? get lastError => state.maybeWhen(
        error: (error, _) => error,
        orElse: () => null,
      );
}

// Created: 2025-01-16 17:30:00
