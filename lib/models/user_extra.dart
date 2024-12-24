import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_extra.freezed.dart';
part 'generated/user_extra.g.dart';

@freezed
class UserExtra with _$UserExtra {
  const factory UserExtra({
    required DateTime createdAt,
    int? status,
    DateTime? latestLoad,
    String? hashPincode,
    bool? emailConfirmed,
    bool? termsConfirmed,
    String? userId,
    required String userExtraId,
    String? saltPincode,
    @Default(true) bool? onboarding,
    String? encryptedMasterkeyCheckValue,
    String? email,
    @Default('user') String? userType,
    @Default(false) bool? securekeyIsSaved,
  }) = _UserExtra;

  factory UserExtra.fromJson(Map<String, dynamic> json) =>
      _$UserExtraFromJson(json);

  static UserExtra? fromDatabaseJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserExtra.fromJson(json);
  }
}
