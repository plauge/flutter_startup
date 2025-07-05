import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/text_codes_provider.g.dart';

@riverpod
TextCodesService textCodesService(TextCodesServiceRef ref) {
  return TextCodesService(Supabase.instance.client);
}

@riverpod
Future<List<TextCodesReadResponse>> readTextCodeByConfirmCode(
  ReadTextCodeByConfirmCodeRef ref,
  String confirmCode,
) async {
  final log = scopedLogger(LogCategory.provider);
  log('readTextCodeByConfirmCode: Processing text code read request from lib/providers/text_codes_provider.dart');
  log('readTextCodeByConfirmCode: Confirm code: $confirmCode');

  try {
    final textCodesService = ref.watch(textCodesServiceProvider);
    final results = await textCodesService.readTextCodeByConfirmCode(confirmCode);

    log('readTextCodeByConfirmCode: Successfully retrieved text codes data');
    log('readTextCodeByConfirmCode: Number of responses: ${results.length}');
    if (results.isNotEmpty) {
      log('readTextCodeByConfirmCode: First response status code: ${results.first.statusCode}');
      log('readTextCodeByConfirmCode: First response success: ${results.first.data.success}');
      log('readTextCodeByConfirmCode: First response message: ${results.first.data.message}');
      log('readTextCodeByConfirmCode: Text codes ID: ${results.first.data.payload.textCodesId}');
      log('readTextCodeByConfirmCode: Receiver read: ${results.first.data.payload.receiverRead}');
    }

    return results;
  } catch (error, stackTrace) {
    log('readTextCodeByConfirmCode: Error: $error');
    log('readTextCodeByConfirmCode: Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2025-01-27 18:32:00
