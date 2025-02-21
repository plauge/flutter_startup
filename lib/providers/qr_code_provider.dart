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
  required String qrCodeId,
}) async {
  final qrCodeService = ref.watch(qrCodeServiceProvider);
  return qrCodeService.readQrCode(qrCodeId: qrCodeId);
}
