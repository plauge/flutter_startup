import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/confirms_realtime.freezed.dart';
part 'generated/confirms_realtime.g.dart';

@freezed
class ConfirmsRealtime with _$ConfirmsRealtime {
  const factory ConfirmsRealtime({
    @JsonKey(name: 'confirms_realtime_id') required String confirmsRealtimeId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'confirms_id') required String confirmsId,
    required int status,
    @JsonKey(name: 'user_id') String? userId,
  }) = _ConfirmsRealtime;

  factory ConfirmsRealtime.fromJson(Map<String, dynamic> json) => _$ConfirmsRealtimeFromJson(json);
}

// Created on 2025-01-27 at 13:45:00
