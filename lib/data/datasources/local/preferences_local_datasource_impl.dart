import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_local_datasource.dart';

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  PreferencesLocalDataSourceImpl({required this.prefs});

  final SharedPreferences prefs;

  @override
  Future<String?> getString(String key) async {
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return prefs.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  @override
  Future<List<String>> getStringList(String key) async {
    return prefs.getStringList(key) ?? <String>[];
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }
}
