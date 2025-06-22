import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/contact_realtime.freezed.dart';
part 'generated/contact_realtime.g.dart';

@freezed
class ContactRealtime with _$ContactRealtime {
  const factory ContactRealtime({
    @JsonKey(name: 'contacts_realtime_id') required String contactsRealtimeId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'contact_user_id') String? contactUserId,
    @Default(false) bool star,
    @JsonKey(name: 'contact_id') String? contactId,
    @JsonKey(name: 'invitation_level_1_id') String? invitationLevel1Id,
    @JsonKey(name: 'invitation_level_3_id') String? invitationLevel3Id,
    @JsonKey(name: 'contact_type') required int contactType,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? company,
    String? email,
    @JsonKey(name: 'profile_image') @Default('') String profileImage,
  }) = _ContactRealtime;

  factory ContactRealtime.fromJson(Map<String, dynamic> json) => _$ContactRealtimeFromJson(json);
}

// Created on 2025-01-26 10:30:00
