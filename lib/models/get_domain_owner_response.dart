import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/get_domain_owner_response.freezed.dart';
part 'generated/get_domain_owner_response.g.dart';

/// Model for the response from the get_domain_owner Supabase endpoint.
@freezed
class GetDomainOwnerResponse with _$GetDomainOwnerResponse {
  const factory GetDomainOwnerResponse({
    @JsonKey(name: 'status_code') required int statusCode,
    required GetDomainOwnerData data,
    @JsonKey(name: 'log_id') required String logId,
  }) = _GetDomainOwnerResponse;

  factory GetDomainOwnerResponse.fromJson(Map<String, dynamic> json) => _$GetDomainOwnerResponseFromJson(json);
}

@freezed
class GetDomainOwnerData with _$GetDomainOwnerData {
  const factory GetDomainOwnerData({
    required String message,
    required GetDomainOwnerPayload payload,
    required bool success,
  }) = _GetDomainOwnerData;

  factory GetDomainOwnerData.fromJson(Map<String, dynamic> json) => _$GetDomainOwnerDataFromJson(json);
}

@freezed
class GetDomainOwnerPayload with _$GetDomainOwnerPayload {
  const factory GetDomainOwnerPayload({
    required int status,
    @JsonKey(name: 'trust_level') required int trustLevel,
    @JsonKey(name: 'validated_at') required String validatedAt,
    @JsonKey(name: 'customer_name') required String customerName,
  }) = _GetDomainOwnerPayload;

  factory GetDomainOwnerPayload.fromJson(Map<String, dynamic> json) => _$GetDomainOwnerPayloadFromJson(json);
}

// File created: 2024-06-08 13:00
