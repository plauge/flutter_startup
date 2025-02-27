import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qr_code_read_response.dart';
import '../services/qr_code_service.dart';

part 'generated/qr_code_provider.g.dart';

@riverpod
QrCodeService qrCodeService(QrCodeServiceRef ref) {
  return QrCodeService(Supabase.instance.client);
}

@riverpod
Future<List<QrCodeReadResponse>> readQrCode(
  ReadQrCodeRef ref, {
  String? qrCodeId,
  String? qrPath,
}) async {
  print('\n=== QR Code Provider: readQrCode ===');
  print('🔍 Reading QR code with ID: $qrCodeId');
  print('🔍 Reading QR path: $qrPath');

  try {
    final qrCodeService = ref.watch(qrCodeServiceProvider);
    final results = await qrCodeService.readQrCode(
      qrCodeId: qrCodeId,
      qrPath: qrPath,
    );

    print('✅ Successfully retrieved QR code data');
    print('📊 Number of responses: ${results.length}');
    if (results.isNotEmpty) {
      print('📋 First response status code: ${results.first.statusCode}');
      print('📋 First response success: ${results.first.data.success}');
      print('📋 First response message: ${results.first.data.message}');
    }

    return results;
  } catch (error, stackTrace) {
    print('❌ Error in QR Code Provider:');
    print('Error: $error');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}
