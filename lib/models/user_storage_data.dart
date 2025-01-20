import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_storage_data.freezed.dart';
part 'generated/user_storage_data.g.dart';

@freezed
class UserStorageData with _$UserStorageData {
  const factory UserStorageData({
    required String email,
    required String token,
    required String testkey,
  }) = _UserStorageData;

  factory UserStorageData.fromJson(Map<String, dynamic> json) =>
      _$UserStorageDataFromJson(json);
}
