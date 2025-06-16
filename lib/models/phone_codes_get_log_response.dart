import 'package:freezed_annotation/freezed_annotation.dart';
import 'phone_code.dart';

part 'generated/phone_codes_get_log_response.freezed.dart';
part 'generated/phone_codes_get_log_response.g.dart';

@freezed
class PhoneCodesGetLogResponse with _$PhoneCodesGetLogResponse {
  const factory PhoneCodesGetLogResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required PhoneCodesGetLogData data,
    @JsonKey(name: 'log_id') required String logId,
  }) = _PhoneCodesGetLogResponse;

  factory PhoneCodesGetLogResponse.fromJson(Map<String, dynamic> json) => _$PhoneCodesGetLogResponseFromJson(json);
}

@freezed
class PhoneCodesGetLogData with _$PhoneCodesGetLogData {
  const factory PhoneCodesGetLogData({
    required String message,
    required PhoneCodesGetLogPayload payload,
    required bool success,
  }) = _PhoneCodesGetLogData;

  factory PhoneCodesGetLogData.fromJson(Map<String, dynamic> json) => _$PhoneCodesGetLogDataFromJson(json);
}

@freezed
class PhoneCodesGetLogPayload with _$PhoneCodesGetLogPayload {
  const factory PhoneCodesGetLogPayload({
    required int count,
    @JsonKey(name: 'phone_codes') required List<PhoneCode> phoneCodes,
    @JsonKey(name: 'receiver_user_id') required String receiverUserId,
  }) = _PhoneCodesGetLogPayload;

  factory PhoneCodesGetLogPayload.fromJson(Map<String, dynamic> json) => _$PhoneCodesGetLogPayloadFromJson(json);
}

// Created: 2025-01-16 14:31:00
