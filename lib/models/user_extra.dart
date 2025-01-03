import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_extra.freezed.dart';
part 'generated/user_extra.g.dart';

@freezed
class UserExtra with _$UserExtra {
  const factory UserExtra({
    required String userExtraId,
    required DateTime createdAt,
    String? userId,
    String? email,
    String? userType,
    @Default(true) bool? onboarding,
    int? status,
    DateTime? latestLoad,
    String? hashPincode,
    String? saltPincode,
    bool? emailConfirmed,
    bool? termsConfirmed,
    @Default(false) bool? securekeyIsSaved,
    String? encryptedMasterkeyCheckValue,
  }) = _UserExtra;

  factory UserExtra.fromJson(Map<String, dynamic> json) =>
      _$UserExtraFromJson(json);
}
