import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/phone_code.freezed.dart';
part 'generated/phone_code.g.dart';

@freezed
class PhoneCode with _$PhoneCode {
  const factory PhoneCode({
    @JsonKey(name: 'phone_codes_id') required String phoneCodesId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'customer_user_id') required String customerUserId,
    @JsonKey(name: 'receiver_user_id') String? receiverUserId,
    @JsonKey(name: 'customer_employee_id') required String customerEmployeeId,
    @JsonKey(name: 'initiator_info') required Map<String, dynamic> initiatorInfo,
    @JsonKey(name: 'confirm_code') required String confirmCode,
    @JsonKey(name: 'initiator_cancel') @Default(false) bool initiatorCancel,
    @JsonKey(name: 'initiator_cancel_updated_at') DateTime? initiatorCancelUpdatedAt,
    @JsonKey(name: 'receiver_read') @Default(false) bool receiverRead,
    @JsonKey(name: 'receiver_read_updated_at') DateTime? receiverReadUpdatedAt,
    @Default(0) int action,
  }) = _PhoneCode;

  factory PhoneCode.fromJson(Map<String, dynamic> json) => _$PhoneCodeFromJson(json);
}

// Created: 2025-01-16 14:30:00
