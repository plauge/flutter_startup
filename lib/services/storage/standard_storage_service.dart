import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/interfaces/storage_interface.dart';

part 'standard_storage_service.g.dart';

class StandardStorageService implements StorageInterface {
  final SharedPreferences _prefs;

  const StandardStorageService(this._prefs);

  @override
  Future<void> saveString(String key, String value) async =>
      await _prefs.setString(key, value);

  @override
  Future<void> saveInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  @override
  Future<void> saveBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> remove(String key) async => await _prefs.remove(key);

  @override
  Future<void> clear() async => await _prefs.clear();
}

@Riverpod(keepAlive: true)
StandardStorageService standardStorage(StandardStorageRef ref) {
  throw UnimplementedError();
}
