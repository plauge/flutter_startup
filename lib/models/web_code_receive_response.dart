import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'generated/web_code_receive_response.freezed.dart';
part 'generated/web_code_receive_response.g.dart';

@freezed
class WebCodeReceiveResponse with _$WebCodeReceiveResponse {
  const factory WebCodeReceiveResponse({
    required int statusCode,
    required WebCodeResponseData data,
    required String logId,
  }) = _WebCodeReceiveResponse;

  factory WebCodeReceiveResponse.fromJson(Map<String, dynamic> json) => _$WebCodeReceiveResponseFromJson(json);
}

@freezed
class WebCodeResponseData with _$WebCodeResponseData {
  const factory WebCodeResponseData({
    required String message,
    required WebCodePayload payload,
    required bool success,
  }) = _WebCodeResponseData;

  factory WebCodeResponseData.fromJson(Map<String, dynamic> json) => _$WebCodeResponseDataFromJson(json);
}

@freezed
class WebCodePayload with _$WebCodePayload {
  const factory WebCodePayload({
    required String domain,
    required String createdAt,
    required String webCodesId,
    required String customerName,
    required String encryptedToken,
    required String customerUserId,
    required String receiverUserId,
    required String encryptedUrlPath,
    required String? encryptedVariables,
  }) = _WebCodePayload;

  factory WebCodePayload.fromJson(Map<String, dynamic> json) => _$WebCodePayloadFromJson(json);
}

// Created: 2023-08-08 15:30:00
