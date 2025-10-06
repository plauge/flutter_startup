import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/do_contacts_have_phone_number_response.freezed.dart';
part 'generated/do_contacts_have_phone_number_response.g.dart';

@freezed
class DoContactsHavePhoneNumberResponse with _$DoContactsHavePhoneNumberResponse {
  const factory DoContactsHavePhoneNumberResponse({
    required int statusCode,
    required DoContactsHavePhoneNumberData data,
    required String logId,
  }) = _DoContactsHavePhoneNumberResponse;

  factory DoContactsHavePhoneNumberResponse.fromJson(Map<String, dynamic> json) => _$DoContactsHavePhoneNumberResponseFromJson(json);
}

@freezed
class DoContactsHavePhoneNumberData with _$DoContactsHavePhoneNumberData {
  const factory DoContactsHavePhoneNumberData({
    required String message,
    required DoContactsHavePhoneNumberPayload payload,
    required bool success,
  }) = _DoContactsHavePhoneNumberData;

  factory DoContactsHavePhoneNumberData.fromJson(Map<String, dynamic> json) => _$DoContactsHavePhoneNumberDataFromJson(json);
}

@freezed
class DoContactsHavePhoneNumberPayload with _$DoContactsHavePhoneNumberPayload {
  const factory DoContactsHavePhoneNumberPayload({
    required String userId,
    required String contactId,
    required int phoneCount,
    required bool hasPhoneNumber,
    required String myContactUserId,
  }) = _DoContactsHavePhoneNumberPayload;

  factory DoContactsHavePhoneNumberPayload.fromJson(Map<String, dynamic> json) => _$DoContactsHavePhoneNumberPayloadFromJson(json);
}

// File created: 2025-01-06 16:00:00
