import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qr_code_read_response.dart';

class QrCodeService {
  final SupabaseClient _client;

  QrCodeService(this._client);

  Future<List<QrCodeReadResponse>> readQrCode({
    String? qrCodeId,
    String? qrPath,
  }) async {
    print('\n=== QR Code Service: readQrCode ===');
    print('📥 Input QR Code ID: $qrCodeId');
    print('📥 Input QR Path: $qrPath');

    try {
      final response = await _client.rpc(
        'qr_code_codes_read',
        params: {
          'input_qr_codes_id': qrCodeId,
          'input_qr_path': qrPath,
        },
      );

      print('📦 Raw response data: $response');

      if (response == null) {
        print('❌ Response is null');
        throw Exception('Response from server is null');
      }

      if (response is! List) {
        print('❌ Response is not a List: ${response.runtimeType}');
        throw Exception('Expected List response, got: ${response.runtimeType}');
      }

      final results = response.map((item) {
        print('\n📋 Processing item:');
        print('Type: ${item.runtimeType}');
        print('Content: $item');

        if (item is! Map<String, dynamic>) {
          print('❌ Item is not a Map: ${item.runtimeType}');
          throw Exception('Expected Map item, got: ${item.runtimeType}');
        }

        return QrCodeReadResponse.fromJson(item);
      }).toList();

      print('✅ Successfully processed ${results.length} QR code responses');
      return results;
    } catch (error, stackTrace) {
      print('❌ Error in QR Code Service:');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to read QR code: $error');
    }
  }
}
