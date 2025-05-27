import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qr_code_read_response.dart';
import '../exports.dart';

class QrCodeService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  QrCodeService(this._client);

  Future<List<QrCodeReadResponse>> readQrCode({
    String? qrCodeId,
    String? qrPath,
  }) async {
    log('\n=== QR Code Service: readQrCode ===');
    log('📥 Input QR Code ID: $qrCodeId');
    log('📥 Input QR Path: $qrPath');

    try {
      final response = await _client.rpc(
        'qr_code_codes_read',
        params: {
          'input_qr_codes_id': qrCodeId,
          'input_qr_path': qrPath,
        },
      );

      log('📦 Raw response data: $response');

      if (response == null) {
        log('❌ Response is null');
        throw Exception('Response from server is null');
      }

      if (response is! List) {
        log('❌ Response is not a List: ${response.runtimeType}');
        throw Exception('Expected List response, got: ${response.runtimeType}');
      }

      final results = response.map((item) {
        log('\n📋 Processing item:');
        log('Type: ${item.runtimeType}');
        log('Content: $item');

        if (item is! Map<String, dynamic>) {
          log('❌ Item is not a Map: ${item.runtimeType}');
          throw Exception('Expected Map item, got: ${item.runtimeType}');
        }

        return QrCodeReadResponse.fromJson(item);
      }).toList();

      log('✅ Successfully processed ${results.length} QR code responses');
      return results;
    } catch (error, stackTrace) {
      log('❌ Error in QR Code Service:');
      log('Error: $error');
      log('Stack trace: $stackTrace');
      throw Exception('Failed to read QR code: $error');
    }
  }
}
