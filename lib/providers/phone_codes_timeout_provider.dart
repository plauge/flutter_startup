import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_codes_timeout_provider.g.dart';

@riverpod
PhoneCodesService phoneCodesTimeoutService(Ref ref) {
  return PhoneCodesService(Supabase.instance.client);
}

@riverpod
class PhoneCodesTimeoutNotifier extends _$PhoneCodesTimeoutNotifier {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Times out a phone code by the receiver.
  /// Returns true if successful, false otherwise.
  Future<void> timeoutPhoneCode(String inputPhoneCodesId) async {
    state = const AsyncValue.loading();

    final log = scopedLogger(LogCategory.provider);
    log('timeoutPhoneCode: Processing phone code timeout request from lib/providers/phone_codes_timeout_provider.dart');
    log('timeoutPhoneCode: Phone codes ID: $inputPhoneCodesId');

    try {
      final phoneCodesService = ref.watch(phoneCodesTimeoutServiceProvider);
      await phoneCodesService.timeoutPhoneCode(inputPhoneCodesId);

      log('timeoutPhoneCode: Successfully timed out phone code');
      state = const AsyncValue.data(true);
    } catch (error, stackTrace) {
      log('❌ timeoutPhoneCode: Error: $error');
      log('❌ timeoutPhoneCode: Stack trace: $stackTrace');
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

// Created: 2025-01-16 18:20:00
