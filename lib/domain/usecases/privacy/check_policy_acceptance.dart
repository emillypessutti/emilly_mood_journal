import '../../repositories/preferences_repository.dart';

class CheckPolicyAcceptance {
  CheckPolicyAcceptance(this.repository);

  final PreferencesRepository repository;

  Future<bool> call(String currentVersion) async {
    final accepted = await repository.getPolicyVersionAccepted();
    return accepted == currentVersion;
  }
}
