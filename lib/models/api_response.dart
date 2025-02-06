import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/api_response.freezed.dart';
part 'generated/api_response.g.dart';

@freezed
class ApiResponse with _$ApiResponse {
  const factory ApiResponse({
    required int statusCode,
    required ApiResponseData data,
    required String logId,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
}

@freezed
class ApiResponseData with _$ApiResponseData {
  const factory ApiResponseData({
    required String message,
    required Map<String, dynamic> payload,
    required bool success,
  }) = _ApiResponseData;

  factory ApiResponseData.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseDataFromJson(json);
}
