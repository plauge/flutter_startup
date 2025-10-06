import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_codes_cancel_provider.g.dart';

@riverpod
PhoneCodesService phoneCodesCancelService(Ref ref) {
  return PhoneCodesService(Supabase.instance.client);
}

@riverpod
class PhoneCodesCancelNotifier extends _$PhoneCodesCancelNotifier {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Cancels a phone code by the initiator.
  /// Returns true if successful, false otherwise.
  Future<void> cancelPhoneCode(String inputPhoneCodesId) async {
    state = const AsyncValue.loading();

    final log = scopedLogger(LogCategory.provider);
    log('cancelPhoneCode: Processing phone code cancellation request from lib/providers/phone_codes_cancel_provider.dart');
    log('cancelPhoneCode: Phone codes ID: $inputPhoneCodesId');

    try {
      final phoneCodesService = ref.watch(phoneCodesCancelServiceProvider);
      await phoneCodesService.cancelPhoneCode(inputPhoneCodesId);

      log('cancelPhoneCode: Successfully cancelled phone code');
      state = const AsyncValue.data(true);
    } catch (error, stackTrace) {
      log('❌ cancelPhoneCode: Error: $error');
      log('❌ cancelPhoneCode: Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
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

// Created: 2025-01-16 18:15:00
