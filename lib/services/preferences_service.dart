import 'package:shared_preferences/shared_preferences.dart';

/// PreferencesService encapsulates specific keys without using clear/removeAll.
class PreferencesService {
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyConsentMarketing = 'consentMarketing'; // bool
  static const String keyPolicyVersionAccepted = 'policyVersionAccepted'; // string
  static const String keyPolicyAcceptedAt = 'acceptedAt'; // iso string

  // --- Legacy static helpers (used by MoodStorage and other parts) ---
  static const String _moodEntriesKey = 'mood_entries';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _firstTimeKey = 'first_time';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userPhotoPathKey = 'userPhotoPath';
  static const String _userPhotoUpdatedAtKey = 'userPhotoUpdatedAt';

  static Future<List<String>> getMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_moodEntriesKey) ?? [];
  }

  static Future<void> setMoodEntries(List<String> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_moodEntriesKey, entries);
  }

  static Future<bool> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyGoalKey) ?? false;
  }

  static Future<void> setDailyGoal(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyGoalKey, enabled);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  // Static wrappers for profile data (compat with existing repository)
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhotoPathKey);
  }

  static Future<void> setUserPhotoPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_userPhotoPathKey);
    } else {
      await prefs.setString(_userPhotoPathKey, path);
    }
  }

  static Future<int?> getUserPhotoUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userPhotoUpdatedAtKey);
  }

  static Future<void> setUserPhotoUpdatedAt(int? timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    if (timestamp == null) {
      await prefs.remove(_userPhotoUpdatedAtKey);
    } else {
      await prefs.setInt(_userPhotoUpdatedAtKey, timestamp);
    }
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhotoPathKey);
    await prefs.remove(_userPhotoUpdatedAtKey);
  }

  // Policy acceptance methods
  static Future<String?> getPolicyVersionAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPolicyVersionAccepted);
  }

  static Future<void> setPolicyAcceptance({
    required String version,
    required DateTime acceptedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPolicyVersionAccepted, version);
    await prefs.setString(keyPolicyAcceptedAt, acceptedAt.toIso8601String());
  }

  // Marketing consent
  static Future<bool?> getConsentMarketing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyConsentMarketing);
  }

  static Future<void> setConsentMarketing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyConsentMarketing, value);
  }
}
