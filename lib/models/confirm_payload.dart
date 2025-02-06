import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/confirm_payload.freezed.dart';
part 'generated/confirm_payload.g.dart';

@freezed
class ConfirmPayload with _$ConfirmPayload {
  const factory ConfirmPayload({
    @JsonKey(name: 'confirms_id') required String confirmsId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required int status,
    @JsonKey(name: 'contacts_id') required String contactsId,
    @JsonKey(name: 'initiator_user_id') String? initiatorUserId,
    @JsonKey(name: 'encrypted_initiator_question')
    String? encryptedInitiatorQuestion,
    @JsonKey(name: 'encrypted_initiator_answer')
    String? encryptedInitiatorAnswer,
    @JsonKey(name: 'initiator_status') int? initiatorStatus,
    @JsonKey(name: 'receiver_user_id') String? receiverUserId,
    @JsonKey(name: 'encrypted_receiver_question')
    String? encryptedReceiverQuestion,
    @JsonKey(name: 'encrypted_receiver_answer') String? encryptedReceiverAnswer,
    @JsonKey(name: 'receiver_status') int? receiverStatus,
    @JsonKey(name: 'new_record') required bool newRecord,
    String? question,
  }) = _ConfirmPayload;

  factory ConfirmPayload.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPayloadFromJson(json);
}
