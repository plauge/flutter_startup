import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_codes_provider.g.dart';

@riverpod
PhoneCodesService phoneCodesService(PhoneCodesServiceRef ref) {
  return PhoneCodesService(Supabase.instance.client);
}

@riverpod
Future<List<PhoneCodesGetLogResponse>> getPhoneCodesLog(
  GetPhoneCodesLogRef ref,
) async {
  final log = scopedLogger(LogCategory.provider);
  log('getPhoneCodesLog: Processing phone codes log request from lib/providers/phone_codes_provider.dart');

  try {
    final phoneCodesService = ref.watch(phoneCodesServiceProvider);
    final results = await phoneCodesService.getPhoneCodesLog();

    log('getPhoneCodesLog: Successfully retrieved phone codes log data');
    log('getPhoneCodesLog: Number of responses: ${results.length}');
    if (results.isNotEmpty) {
      log('getPhoneCodesLog: First response status code: ${results.first.statusCode}');
      log('getPhoneCodesLog: First response success: ${results.first.data.success}');
      log('getPhoneCodesLog: First response message: ${results.first.data.message}');
      log('getPhoneCodesLog: Phone codes count: ${results.first.data.payload.count}');
    }

    return results;
  } catch (error, stackTrace) {
    log('getPhoneCodesLog: Error: $error');
    log('getPhoneCodesLog: Stack trace: $stackTrace');
    rethrow;
  }
}

@riverpod
Future<void> markPhoneCodeAsRead(
  MarkPhoneCodeAsReadRef ref,
  String phoneCodesId,
) async {
  final log = scopedLogger(LogCategory.provider);
  log('markPhoneCodeAsRead: Processing mark phone code as read request from lib/providers/phone_codes_provider.dart');
  log('markPhoneCodeAsRead: Phone codes ID: $phoneCodesId');

  try {
    final phoneCodesService = ref.watch(phoneCodesServiceProvider);
    await phoneCodesService.markPhoneCodeAsRead(phoneCodesId);

    log('markPhoneCodeAsRead: Successfully marked phone code as read');
  } catch (error, stackTrace) {
    log('markPhoneCodeAsRead: Error: $error');
    log('markPhoneCodeAsRead: Stack trace: $stackTrace');
    rethrow;
  }
}

@riverpod
Future<void> markPhoneCodeAsRejected(
  MarkPhoneCodeAsRejectedRef ref,
  String phoneCodesId,
) async {
  final log = scopedLogger(LogCategory.provider);
  log('markPhoneCodeAsRejected: Processing mark phone code as rejected request from lib/providers/phone_codes_provider.dart');
  log('markPhoneCodeAsRejected: Phone codes ID: $phoneCodesId');

  try {
    final phoneCodesService = ref.watch(phoneCodesServiceProvider);
    await phoneCodesService.markPhoneCodeAsRejected(phoneCodesId);

    log('markPhoneCodeAsRejected: Successfully marked phone code as rejected');
  } catch (error, stackTrace) {
    log('markPhoneCodeAsRejected: Error: $error');
    log('markPhoneCodeAsRejected: Stack trace: $stackTrace');
    rethrow;
  }
}

// Created: 2025-01-16 14:33:00
