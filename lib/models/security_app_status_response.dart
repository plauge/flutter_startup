import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/security_app_status_response.freezed.dart';
part 'generated/security_app_status_response.g.dart';

/// Model for the response from the security_get_app_status Supabase endpoint.
@freezed
class SecurityAppStatusResponse with _$SecurityAppStatusResponse {
  const factory SecurityAppStatusResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required SecurityAppStatusData data,
    @JsonKey(name: 'log_id') required String logId,
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
  }) = _SecurityAppStatusPayload;

  factory SecurityAppStatusPayload.fromJson(Map<String, dynamic> json) => _$SecurityAppStatusPayloadFromJson(json);
}

// File created: 2025-01-06 15:30
