import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/web_code_receive_response.dart';
import '../services/web_code_service.dart';
import '../exports.dart';

part 'generated/web_code_provider.g.dart';

@riverpod
WebCodeService webCodeService(WebCodeServiceRef ref) {
  return WebCodeService(Supabase.instance.client);
}

@riverpod
Future<List<WebCodeReceiveResponse>> receiveWebCode(
  ReceiveWebCodeRef ref, {
  required String webCodesId,
}) async {
  final log = scopedLogger(LogCategory.provider);
  log('receiveWebCode: Processing web code ID: $webCodesId');

  try {
    final webCodeService = ref.watch(webCodeServiceProvider);
    final results = await webCodeService.receiveWebCode(
      webCodesId: webCodesId,
    );

    log('receiveWebCode: Successfully retrieved web code data');
    log('receiveWebCode: Number of responses: ${results.length}');
    if (results.isNotEmpty) {
      log('receiveWebCode: First response status code: ${results.first.statusCode}');
      log('receiveWebCode: First response success: ${results.first.data.success}');
      log('receiveWebCode: First response message: ${results.first.data.message}');
    }

    return results;
  } catch (error, stackTrace) {
    log('receiveWebCode: Error: $error');
    log('receiveWebCode: Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2023-08-08 15:40:00
