import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/qr_code_read_response.freezed.dart';
part 'generated/qr_code_read_response.g.dart';

@freezed
class QrCodeReadResponse with _$QrCodeReadResponse {
  const factory QrCodeReadResponse({
    required int statusCode,
    required QrCodeReadData data,
    required String logId,
  }) = _QrCodeReadResponse;

  factory QrCodeReadResponse.fromJson(Map<String, dynamic> json) =>
      _$QrCodeReadResponseFromJson(json);
}

@freezed
class QrCodeReadData with _$QrCodeReadData {
  const factory QrCodeReadData({
    required String message,
    required QrCodePayload payload,
    required bool success,
  }) = _QrCodeReadData;

  factory QrCodeReadData.fromJson(Map<String, dynamic> json) =>
      _$QrCodeReadDataFromJson(json);
}

@freezed
class QrCodePayload with _$QrCodePayload {
  const factory QrCodePayload({
    required DateTime createdAt,
    required String qrCodeType,
    required String encryptedAction,
    required String encryptedUserNote,
  }) = _QrCodePayload;

  factory QrCodePayload.fromJson(Map<String, dynamic> json) =>
      _$QrCodePayloadFromJson(json);
}
