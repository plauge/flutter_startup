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

    print('Raw response: $response');
    print('Response type: ${response.runtimeType}');

    if (response['status_code'] == 200) {
      state = AsyncData(response);
      return response;
    } else {
      final error = 'Error: ${response['message'] ?? 'Unknown error'}';
      state = AsyncError(error, StackTrace.current);
      throw Exception(error);
    }
  }
}
