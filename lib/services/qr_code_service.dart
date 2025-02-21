import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qr_code_read_response.dart';

class QrCodeService {
  final SupabaseClient _client;

  QrCodeService(this._client);

  Future<List<QrCodeReadResponse>> readQrCode({
    required String qrCodeId,
  }) async {
    try {
      final response = await _client.rpc(
        'qr_code_codes_read',
        params: {'input_qr_codes_id': qrCodeId},
      );

      return (response as List)
          .map((item) =>
              QrCodeReadResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Failed to read QR code: $error');
    }
  }
}
