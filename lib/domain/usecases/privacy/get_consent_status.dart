import '../../repositories/preferences_repository.dart';

class ConsentStatus {
  const ConsentStatus({required this.versionAccepted, required this.marketingAccepted});

  final String? versionAccepted;
  final bool marketingAccepted;
}

class GetConsentStatus {
  GetConsentStatus(this.repository);

  final PreferencesRepository repository;

  Future<ConsentStatus> call() async {
    final version = await repository.getPolicyVersionAccepted();
    final marketing = await repository.getConsentMarketing();
    return ConsentStatus(versionAccepted: version, marketingAccepted: marketing);
  }
}
