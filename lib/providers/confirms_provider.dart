import 'package:flutter_startup/exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/confirms_provider.g.dart';

@riverpod
ConfirmsService confirmsService(ConfirmsServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ConfirmsService(supabase);
}

@riverpod
class ConfirmsConfirm extends _$ConfirmsConfirm {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return {};
  }

  Future<Map<String, dynamic>> confirm({
    required String contactsId,
    required String question,
  }) async {
    state = const AsyncLoading();

    final response = await ref.read(confirmsServiceProvider).confirmConfirm(
          contactsId: contactsId,
          question: question,
        );

    debugPrint('Raw response: $response');
    debugPrint('Response type: ${response.runtimeType}');

    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsRecieverUpdate({
    required String answer,
    required String confirmsId,
  }) async {
    state = const AsyncLoading();
    await ref.read(confirmsServiceProvider).confirmsRecieverUpdate(
          answer: answer,
          confirmsId: confirmsId,
        );
    // Return empty map to match the state type
    return {};
  }
}

@riverpod
class ConfirmsWatch extends _$ConfirmsWatch {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return {};
  }

  Future<Map<String, dynamic>> watch({
    required String confirmsId,
  }) async {
    state = const AsyncLoading();

    final response = await ref.read(confirmsServiceProvider).watch(
          confirmsId: confirmsId,
        );

    debugPrint('Raw response: $response');
    debugPrint('Response type: ${response.runtimeType}');

    state = AsyncData(response);
    return response;
  }
}
