abstract interface class StorageInterface {
  Future<void> saveString(String key, String value);
  Future<void> saveInt(String key, int value);
  Future<void> saveBool(String key, bool value);
  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
