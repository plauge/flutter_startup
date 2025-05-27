import 'package:idtruster/exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/confirms_provider.g.dart';

@riverpod
ConfirmsService confirmsService(ConfirmsServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ConfirmsService(supabase);
}

@riverpod
class ConfirmsConfirm extends _$ConfirmsConfirm {
  static final log = scopedLogger(LogCategory.provider);
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

    log('Raw response: $response');
    log('Response type: ${response.runtimeType}');

    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsRecieverUpdate({
    required String answer,
    required String confirmsId,
  }) async {
    log('🔶 ConfirmsProvider - Starting confirmsRecieverUpdate');
    state = const AsyncLoading();

    final response = await ref.read(confirmsServiceProvider).confirmsRecieverUpdate(
          answer: answer,
          confirmsId: confirmsId,
        );

    log('🔶 ConfirmsProvider - Response received: $response');
    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsInitiatorUpdate({
    required String answer,
    required String confirmsId,
  }) async {
    log('🔶 ConfirmsProvider - Starting confirmsInitiatorUpdate');
    state = const AsyncLoading();

    final response = await ref.read(confirmsServiceProvider).confirmsInitiatorUpdate(
          answer: answer,
          confirmsId: confirmsId,
        );

    log('🔶 ConfirmsProvider - Response received: $response');
    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsRecieverFinish({
    required String confirmsId,
  }) async {
    log('🔶 ConfirmsProvider - Starting confirmsRecieverFinish');
    state = const AsyncLoading();
    final response = await ref.read(confirmsServiceProvider).confirmsRecieverFinish(
          confirmsId: confirmsId,
        );
    log('🔶 ConfirmsProvider - Response received: $response');
    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsInitiatorFinish({
    required String confirmsId,
  }) async {
    log('🔶 ConfirmsProvider - Starting confirmsInitiatorFinish');
    state = const AsyncLoading();
    final response = await ref.read(confirmsServiceProvider).confirmsInitiatorFinish(
          confirmsId: confirmsId,
        );
    log('🔶 ConfirmsProvider - Response received: $response');
    state = AsyncData(response);
    return response;
  }

  Future<Map<String, dynamic>> confirmsDelete({
    required String contactsId,
  }) async {
    log('🔶 ConfirmsProvider - Starting confirmsDelete');
    state = const AsyncLoading();
    final response = await ref.read(confirmsServiceProvider).confirmsDelete(
          contactsId: contactsId,
        );
    log('🔶 ConfirmsProvider - Response received: $response');
    state = AsyncData(response);
    return response;
  }
}

@riverpod
class ConfirmsWatch extends _$ConfirmsWatch {
  static final log = scopedLogger(LogCategory.provider);
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

    log('Raw response: $response');
    log('Response type: ${response.runtimeType}');

    state = AsyncData(response);
    return response;
  }
}
