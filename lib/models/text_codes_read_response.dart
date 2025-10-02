import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/text_codes_read_response.freezed.dart';
part 'generated/text_codes_read_response.g.dart';

@freezed
class TextCodesReadResponse with _$TextCodesReadResponse {
  const factory TextCodesReadResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required TextCodesReadData data,
    @JsonKey(name: 'log_id') required String logId,
  }) = _TextCodesReadResponse;

  factory TextCodesReadResponse.fromJson(Map<String, dynamic> json) => _$TextCodesReadResponseFromJson(json);
}

@freezed
class TextCodesReadData with _$TextCodesReadData {
  const factory TextCodesReadData({
    required String message,
    required TextCodesReadPayload payload,
    required bool success,
  }) = _TextCodesReadData;

  factory TextCodesReadData.fromJson(Map<String, dynamic> json) => _$TextCodesReadDataFromJson(json);
}

@freezed
class TextCodesReadPayload with _$TextCodesReadPayload {
  const factory TextCodesReadPayload({
    required int action,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'confirm_code') required String confirmCode,
    @JsonKey(name: 'receiver_read') required bool receiverRead,
    @JsonKey(name: 'text_codes_id') required String textCodesId,
    @JsonKey(name: 'initiator_info') InitiatorInfo? initiatorInfo,
    @JsonKey(name: 'customer_user_id') required String customerUserId,
    @JsonKey(name: 'receiver_user_id') required String receiverUserId,
    @JsonKey(name: 'customer_employee_id') required String customerEmployeeId,
    @JsonKey(name: 'receiver_read_updated_at') DateTime? receiverReadUpdatedAt,
    @JsonKey(name: 'text_code_type') @Default('customer') String textCodesType,
  }) = _TextCodesReadPayload;

  factory TextCodesReadPayload.fromJson(Map<String, dynamic> json) => _$TextCodesReadPayloadFromJson(json);
}

@freezed
class InitiatorInfo with _$InitiatorInfo {
  const factory InitiatorInfo({
    String? name,
    String? email,
    String? phone,
    InitiatorAddress? address,
    String? company,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'last_control') DateTime? lastControl,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'contact_id') String? contactId,
  }) = _InitiatorInfo;

  factory InitiatorInfo.fromJson(Map<String, dynamic> json) => _$InitiatorInfoFromJson(json);
}

@freezed
class InitiatorAddress with _$InitiatorAddress {
  const factory InitiatorAddress({
    String? city,
    String? region,
    String? street,
    String? country,
    @JsonKey(name: 'postal_code') String? postalCode,
  }) = _InitiatorAddress;

  factory InitiatorAddress.fromJson(Map<String, dynamic> json) => _$InitiatorAddressFromJson(json);
}

// Created: 2025-01-27 18:30:00
