abstract class PreferencesRepository {
  // LGPD / Privacy
  Future<String?> getPolicyVersionAccepted();
  Future<void> setPolicyAcceptance(String version, int timestampMillis);
  Future<bool> getConsentMarketing();
  Future<void> setConsentMarketing(bool consent);

  // App state
  Future<bool> isFirstTime();
  Future<void> setFirstTimeCompleted();
  Future<bool> getDailyGoal();
  Future<void> setDailyGoal(bool enabled);
}
