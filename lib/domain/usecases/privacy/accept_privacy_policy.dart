import '../../repositories/preferences_repository.dart';

class AcceptPrivacyPolicy {
  AcceptPrivacyPolicy(this.repository);

  final PreferencesRepository repository;

  Future<void> call({required String version, required bool marketingConsent}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await repository.setPolicyAcceptance(version, now);
    await repository.setConsentMarketing(marketingConsent);
  }
}
