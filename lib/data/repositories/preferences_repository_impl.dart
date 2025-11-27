import '../../domain/repositories/preferences_repository.dart';
import '../datasources/local/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl({required this.local});

  final PreferencesLocalDataSource local;

  static const _keyPolicyVersion = 'policy_version_accepted';
  static const _keyPolicyTimestamp = 'policy_timestamp';
  static const _keyConsentMarketing = 'consent_marketing';
  static const _keyFirstTime = 'first_time_completed_v1';
  static const _keyDailyGoal = 'daily_goal_enabled_v1';

  @override
  Future<String?> getPolicyVersionAccepted() async {
    return await local.getString(_keyPolicyVersion);
  }

  @override
  Future<void> setPolicyAcceptance(String version, int timestampMillis) async {
    await local.setString(_keyPolicyVersion, version);
    await local.setInt(_keyPolicyTimestamp, timestampMillis);
  }

  @override
  Future<bool> getConsentMarketing() async {
    return await local.getBool(_keyConsentMarketing, defaultValue: false);
  }

  @override
  Future<void> setConsentMarketing(bool consent) async {
    await local.setBool(_keyConsentMarketing, consent);
  }

  @override
  Future<bool> isFirstTime() async {
    // If not set, consider first time true
    final completed = await local.getBool(_keyFirstTime, defaultValue: false);
    return !completed;
  }

  @override
  Future<void> setFirstTimeCompleted() async {
    await local.setBool(_keyFirstTime, true);
  }

  @override
  Future<bool> getDailyGoal() async {
    return await local.getBool(_keyDailyGoal, defaultValue: false);
  }

  @override
  Future<void> setDailyGoal(bool enabled) async {
    await local.setBool(_keyDailyGoal, enabled);
  }
}
