import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'generated/phone_numbers_response.freezed.dart';
part 'generated/phone_numbers_response.g.dart';

@freezed
class PhoneNumbersResponse with _$PhoneNumbersResponse {
  const factory PhoneNumbersResponse({
    required int statusCode,
    required PhoneNumbersResponseData data,
    required String logId,
  }) = _PhoneNumbersResponse;

  factory PhoneNumbersResponse.fromJson(Map<String, dynamic> json) => _$PhoneNumbersResponseFromJson(json);
}

@freezed
class PhoneNumbersResponseData with _$PhoneNumbersResponseData {
  const factory PhoneNumbersResponseData({
    required String message,
    required List<PhoneNumberItem> payload,
    required bool success,
  }) = _PhoneNumbersResponseData;

  factory PhoneNumbersResponseData.fromJson(Map<String, dynamic> json) => _$PhoneNumbersResponseDataFromJson(json);
}

@freezed
class PhoneNumberItem with _$PhoneNumberItem {
  const factory PhoneNumberItem({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'primary_phone') required bool primaryPhone,
    @JsonKey(name: 'salt_phone_number') required String saltPhoneNumber,
    @JsonKey(name: 'user_phone_numbers_id') required String userPhoneNumbersId,
    @JsonKey(name: 'encrypted_phone_number') required String encryptedPhoneNumber,
  }) = _PhoneNumberItem;

  factory PhoneNumberItem.fromJson(Map<String, dynamic> json) => _$PhoneNumberItemFromJson(json);
}

// Created: 2024-12-30 14:30:00
