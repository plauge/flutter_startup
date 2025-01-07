import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/contact.freezed.dart';
part 'generated/contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String contactId,
    @JsonKey(name: 'is_new', fromJson: _intToBool) required bool isNew,
    required bool star,
    required int count,
    String? contactType,
    required String firstName,
    required String lastName,
    required String company,
    required String email,
    @Default('') String profileImage,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}

bool _intToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  return false;
}
