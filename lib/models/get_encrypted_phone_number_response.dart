import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/get_encrypted_phone_number_response.freezed.dart';
part 'generated/get_encrypted_phone_number_response.g.dart';

@freezed
class GetEncryptedPhoneNumberResponse with _$GetEncryptedPhoneNumberResponse {
  const factory GetEncryptedPhoneNumberResponse({
    required int statusCode,
    required GetEncryptedPhoneNumberData data,
    required String logId,
  }) = _GetEncryptedPhoneNumberResponse;

  factory GetEncryptedPhoneNumberResponse.fromJson(Map<String, dynamic> json) => _$GetEncryptedPhoneNumberResponseFromJson(json);
}

@freezed
class GetEncryptedPhoneNumberData with _$GetEncryptedPhoneNumberData {
  const factory GetEncryptedPhoneNumberData({
    required String message,
    required GetEncryptedPhoneNumberPayload payload,
    required bool success,
  }) = _GetEncryptedPhoneNumberData;

  factory GetEncryptedPhoneNumberData.fromJson(Map<String, dynamic> json) => _$GetEncryptedPhoneNumberDataFromJson(json);
}

@freezed
class GetEncryptedPhoneNumberPayload with _$GetEncryptedPhoneNumberPayload {
  const factory GetEncryptedPhoneNumberPayload({
    required String userId,
    required String encryptedPhoneNumber,
  }) = _GetEncryptedPhoneNumberPayload;

  factory GetEncryptedPhoneNumberPayload.fromJson(Map<String, dynamic> json) => _$GetEncryptedPhoneNumberPayloadFromJson(json);
}

// File created: 2025-01-06 15:45:00
