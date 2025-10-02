import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/text_code_create_provider.g.dart';

@riverpod
TextCodeCreateService textCodeCreateService(Ref ref) {
  return TextCodeCreateService(Supabase.instance.client);
}

@riverpod
class TextCodeCreateNotifier extends _$TextCodeCreateNotifier {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  /// Creates a new text code for the specified contact.
  /// Returns true if successful (status_code 200), false otherwise.
  Future<void> createTextCodeByUser(String inputContactId) async {
    state = const AsyncValue.loading();

    final log = scopedLogger(LogCategory.provider);
    log('createTextCodeByUser: Processing text code creation request from lib/providers/text_code_create_provider.dart');
    log('createTextCodeByUser: Contact ID: $inputContactId');

    try {
      final textCodeCreateService = ref.watch(textCodeCreateServiceProvider);
      final success = await textCodeCreateService.createTextCodeByUser(
        inputContactId: inputContactId,
      );

      if (success) {
        log('createTextCodeByUser: Successfully created text code');
        state = const AsyncValue.data(true);
      } else {
        log('❌ createTextCodeByUser: Failed to create text code');
        state = const AsyncValue.data(false);
      }
    } catch (error, stackTrace) {
      log('❌ createTextCodeByUser: Error: $error');
      log('❌ createTextCodeByUser: Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Creates a text code and returns the detailed response data.
  Future<TextCodeCreateResponse?> createTextCodeDetailed(String inputContactId) async {
    final log = scopedLogger(LogCategory.provider);
    log('createTextCodeDetailed: Processing detailed text code creation request from lib/providers/text_code_create_provider.dart');
    log('createTextCodeDetailed: Contact ID: $inputContactId');

    try {
      final textCodeCreateService = ref.watch(textCodeCreateServiceProvider);
      final response = await textCodeCreateService.createTextCodeByUserDetailed(
        inputContactId: inputContactId,
      );

      if (response != null && response.statusCode == 200) {
        log('createTextCodeDetailed: Successfully created text code');
        log('createTextCodeDetailed: Text codes ID: ${response.data.payload.textCodesId}');
        log('createTextCodeDetailed: Confirm code: ${response.data.payload.confirmCode}');
      } else {
        log('❌ createTextCodeDetailed: Failed to create text code or unexpected response');
      }

      return response;
    } catch (error, stackTrace) {
      log('❌ createTextCodeDetailed: Error: $error');
      log('❌ createTextCodeDetailed: Stack trace: $stackTrace');
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

// Created: 2025-01-16 18:30:00
