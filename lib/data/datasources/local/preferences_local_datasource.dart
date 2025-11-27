abstract class PreferencesLocalDataSource {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);

  Future<bool> getBool(String key, {bool defaultValue});
  Future<void> setBool(String key, bool value);

  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);

  Future<List<String>> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);

  Future<void> remove(String key);
}
