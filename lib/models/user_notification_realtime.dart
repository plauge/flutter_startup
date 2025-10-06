import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_notification_realtime.freezed.dart';
part 'generated/user_notification_realtime.g.dart';

@freezed
class UserNotificationRealtime with _$UserNotificationRealtime {
  const factory UserNotificationRealtime({
    @JsonKey(name: 'user_notification_realtime_id') required String userNotificationRealtimeId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'phone_codes_id') required String phoneCodesId,
    @JsonKey(name: 'user_id') required String userId,
    @Default(0) int action,
    @JsonKey(name: 'encrypted_phone_number') @Default('') String encryptedPhoneNumber,
  }) = _UserNotificationRealtime;

  factory UserNotificationRealtime.fromJson(Map<String, dynamic> json) => _$UserNotificationRealtimeFromJson(json);
}

// Created: 2025-01-16 20:00:00
