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
}
