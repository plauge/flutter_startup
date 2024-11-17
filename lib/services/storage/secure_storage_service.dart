import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/interfaces/storage_interface.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService implements StorageInterface {
  final _storage = const FlutterSecureStorage();

  const SecureStorageService();

  @override
  Future<void> saveString(String key, String value) async =>
      await _storage.write(key: key, value: value);

  @override
  Future<void> saveInt(String key, int value) async =>
      await _storage.write(key: key, value: value.toString());

  @override
  Future<void> saveBool(String key, bool value) async =>
      await _storage.write(key: key, value: value.toString());

  @override
  Future<String?> getString(String key) async => await _storage.read(key: key);

  @override
  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  @override
  Future<void> remove(String key) async => await _storage.delete(key: key);

  @override
  Future<void> clear() async => await _storage.deleteAll();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(SecureStorageRef ref) {
  return const SecureStorageService();
}
