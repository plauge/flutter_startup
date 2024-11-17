import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/storage_constants.dart';
import '../../core/interfaces/storage_interface.dart';
import '../../services/storage/standard_storage_service.dart';
import '../../services/storage/secure_storage_service.dart';

part 'storage_provider.g.dart';

@Riverpod(keepAlive: true)
class Storage extends _$Storage {
  @override
  FutureOr<void> build() async {}

  StorageInterface _getStorage(bool secure) {
    return secure
        ? ref.read(secureStorageProvider)
        : ref.read(standardStorageProvider);
  }

  Future<void> saveString(String key, String value,
      {bool secure = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = _getStorage(secure);
      await storage.saveString(key, value);
    });
  }

  Future<String?> getString(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return storage.getString(key);
  }

  Future<void> saveInt(String key, int value, {bool secure = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = _getStorage(secure);
      await storage.saveInt(key, value);
    });
  }

  Future<int?> getInt(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return storage.getInt(key);
  }

  Future<void> saveBool(String key, bool value, {bool secure = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = _getStorage(secure);
      await storage.saveBool(key, value);
    });
  }

  Future<bool?> getBool(String key, {bool secure = false}) async {
    final storage = _getStorage(secure);
    return storage.getBool(key);
  }

  Future<void> remove(String key, {bool secure = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = _getStorage(secure);
      await storage.remove(key);
    });
  }

  Future<void> clear({bool secure = false}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = _getStorage(secure);
      await storage.clear();
    });
  }
}
