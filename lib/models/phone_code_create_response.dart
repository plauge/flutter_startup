import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/phone_code_create_response.freezed.dart';
part 'generated/phone_code_create_response.g.dart';

@freezed
class PhoneCodeCreateResponse with _$PhoneCodeCreateResponse {
  const factory PhoneCodeCreateResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required PhoneCodeCreateData data,
    @JsonKey(name: 'log_id') required String logId,
  }) = _PhoneCodeCreateResponse;

  factory PhoneCodeCreateResponse.fromJson(Map<String, dynamic> json) => _$PhoneCodeCreateResponseFromJson(json);
}

@freezed
class PhoneCodeCreateData with _$PhoneCodeCreateData {
  const factory PhoneCodeCreateData({
    required String message,
    required PhoneCodeCreatePayload payload,
    required bool success,
  }) = _PhoneCodeCreateData;

  factory PhoneCodeCreateData.fromJson(Map<String, dynamic> json) => _$PhoneCodeCreateDataFromJson(json);
}

@freezed
class PhoneCodeCreatePayload with _$PhoneCodeCreatePayload {
  const factory PhoneCodeCreatePayload({
    @JsonKey(name: 'contact_id') required String contactId,
    @JsonKey(name: 'confirm_code') required String confirmCode,
    @JsonKey(name: 'phone_codes_id') required String phoneCodesId,
  }) = _PhoneCodeCreatePayload;

  factory PhoneCodeCreatePayload.fromJson(Map<String, dynamic> json) => _$PhoneCodeCreatePayloadFromJson(json);
}

// Created: 2025-01-16 17:30:00
