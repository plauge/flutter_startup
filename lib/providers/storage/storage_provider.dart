import 'package:id_truster/core/interfaces/storage_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../../core/constants/storage_constants.dart';
import '../../services/storage/standard_storage_service.dart';
import '../../services/storage/secure_storage_service.dart';
import '../../models/user_storage_data.dart';

part 'storage_provider.g.dart';

const String kUserStorageKey = 'vaka_user_storage';

@Riverpod(keepAlive: true)
class Storage extends _$Storage {
  @override
  Future<void> build() async {}

  StorageInterface _getStorage(bool secure) {
    return secure
        ? ref.read(secureStorageProvider)
        : ref.read(standardStorageProvider);
  }

  Future<List<UserStorageData>> getUserStorageData() async {
    final storage = _getStorage(true);
    final jsonString = await storage.getString(kUserStorageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => UserStorageData.fromJson(json)).toList();
  }

  Future<UserStorageData?> getUserStorageDataByEmail(String email) async {
    final List<UserStorageData> data = await getUserStorageData();
    return data.where((item) => item.email == email).firstOrNull;
  }

  Future<void> deleteUserStorageDataByEmail(String email) async {
    final List<UserStorageData> data = await getUserStorageData();
    final updatedData = data.where((item) => item.email != email).toList();
    await _saveUserStorageData(updatedData);
  }

  Future<void> _saveUserStorageData(List<UserStorageData> data) async {
    final storage = _getStorage(true);
    final jsonString = json.encode(data.map((item) => item.toJson()).toList());
    await storage.saveString(kUserStorageKey, jsonString);
  }

  Future<void> saveString(String key, String value,
      {bool secure = false}) async {
    final storage = _getStorage(secure);
    await storage.saveString(key, value);
  }

  Future<String?> getString(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return await storage.getString(key);
  }

  Future<void> saveInt(String key, int value, {bool secure = false}) async {
    final storage = _getStorage(secure);
    await storage.saveInt(key, value);
  }

  Future<int?> getInt(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return await storage.getInt(key);
  }

  Future<void> saveBool(String key, bool value, {bool secure = false}) async {
    final storage = _getStorage(secure);
    await storage.saveBool(key, value);
  }

  Future<bool?> getBool(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return await storage.getBool(key);
  }

  Future<void> remove(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    await storage.remove(key);
  }

  Future<void> clear({bool secure = false}) async {
    final storage = _getStorage(secure);
    await storage.clear();
  }
}
