import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/text_code_create_response.freezed.dart';
part 'generated/text_code_create_response.g.dart';

@freezed
class TextCodeCreateResponse with _$TextCodeCreateResponse {
  const factory TextCodeCreateResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required TextCodeCreateData data,
    @JsonKey(name: 'log_id') required String logId,
  }) = _TextCodeCreateResponse;

  factory TextCodeCreateResponse.fromJson(Map<String, dynamic> json) => _$TextCodeCreateResponseFromJson(json);
}

@freezed
class TextCodeCreateData with _$TextCodeCreateData {
  const factory TextCodeCreateData({
    required String message,
    required TextCodeCreatePayload payload,
    required bool success,
  }) = _TextCodeCreateData;

  factory TextCodeCreateData.fromJson(Map<String, dynamic> json) => _$TextCodeCreateDataFromJson(json);
}

@freezed
class TextCodeCreatePayload with _$TextCodeCreatePayload {
  const factory TextCodeCreatePayload({
    @JsonKey(name: 'contact_id') required String contactId,
    @JsonKey(name: 'confirm_code') required String confirmCode,
    @JsonKey(name: 'text_codes_id') required String textCodesId,
  }) = _TextCodeCreatePayload;

  factory TextCodeCreatePayload.fromJson(Map<String, dynamic> json) => _$TextCodeCreatePayloadFromJson(json);
}

// Created: 2025-01-16 18:30:00
