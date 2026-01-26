import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/security_app_status_response.freezed.dart';
part 'generated/security_app_status_response.g.dart';

/// Model for the response from the security_get_app_status Supabase endpoint.
@freezed
class SecurityAppStatusResponse with _$SecurityAppStatusResponse {
  const factory SecurityAppStatusResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required SecurityAppStatusData data,
    @JsonKey(name: 'log_id') String? logId,
  }) = _SecurityAppStatusResponse;

  factory SecurityAppStatusResponse.fromJson(Map<String, dynamic> json) => _$SecurityAppStatusResponseFromJson(json);
}

@freezed
class SecurityAppStatusData with _$SecurityAppStatusData {
  const factory SecurityAppStatusData({
    required String message,
    required SecurityAppStatusPayload payload,
    required bool success,
  }) = _SecurityAppStatusData;

  factory SecurityAppStatusData.fromJson(Map<String, dynamic> json) => _$SecurityAppStatusDataFromJson(json);
}

@freezed
class RingToneOption with _$RingToneOption {
  const factory RingToneOption({
    required String text,
    required String value,
  }) = _RingToneOption;

  factory RingToneOption.fromJson(Map<String, dynamic> json) => _$RingToneOptionFromJson(json);
}

@freezed
class SecurityAppStatusPayload with _$SecurityAppStatusPayload {
  const factory SecurityAppStatusPayload({
    required String terms,
    @JsonKey(name: 'app_status_id') required String appStatusId,
    @JsonKey(name: 'event_log_active') required bool eventLogActive,
    @JsonKey(name: 'maintenance_mode') required bool maintenanceMode,
    @JsonKey(name: 'secure_key_step_1') required String secureKeyStep1,
    @JsonKey(name: 'secure_key_step_2') required String secureKeyStep2,
    @JsonKey(name: 'maintenance_message') required String maintenanceMessage,
    @JsonKey(name: 'waiting_list_active') required bool waitingListActive,
    @JsonKey(name: 'account_creation_ceiling') required int accountCreationCeiling,
    @JsonKey(name: 'minimum_required_version') required int minimumRequiredVersion,
    @JsonKey(name: 'maintenance_message_updated_at') required DateTime maintenanceMessageUpdatedAt,
    @JsonKey(name: 'onboarding_validate_invite_code') required bool onboardingValidateInviteCode,
    @JsonKey(name: 'supported_country_codes') required List<String> supportedCountryCodes,
    @JsonKey(name: 'phone_iphone') required String phoneIphone,
    @JsonKey(name: 'phone_android') required String phoneAndroid,
    @JsonKey(name: 'supported_ring_tones') required List<RingToneOption> supportedRingTones,
    @Default(false) @JsonKey(name: 'app_feature_flag_1') bool appFeatureFlag1,
    @Default(false) @JsonKey(name: 'app_feature_flag_2') bool appFeatureFlag2,
    @Default(false) @JsonKey(name: 'app_feature_flag_3') bool appFeatureFlag3,
    @Default(false) @JsonKey(name: 'app_feature_flag_4') bool appFeatureFlag4,
  }) = _SecurityAppStatusPayload;

  factory SecurityAppStatusPayload.fromJson(Map<String, dynamic> json) => _$SecurityAppStatusPayloadFromJson(json);
}

// File created: 2025-01-06 15:30
