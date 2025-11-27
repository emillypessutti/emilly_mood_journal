import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/preferences_local_datasource.dart';
import '../data/datasources/local/preferences_local_datasource_impl.dart';
import '../data/repositories/preferences_repository_impl.dart';

import '../domain/repositories/preferences_repository.dart';
import '../domain/usecases/privacy/accept_privacy_policy.dart';
import '../domain/usecases/privacy/check_policy_acceptance.dart';
import '../domain/usecases/privacy/get_consent_status.dart';

// Provide SharedPreferences instance (must be overridden in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

// Data source
final preferencesLocalDataSourceProvider = Provider<PreferencesLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesLocalDataSourceImpl(prefs: prefs);
});

// Repository
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final ds = ref.watch(preferencesLocalDataSourceProvider);
  return PreferencesRepositoryImpl(local: ds);
});

// Use cases
final checkPolicyAcceptanceProvider = Provider<CheckPolicyAcceptance>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return CheckPolicyAcceptance(repo);
});

final acceptPrivacyPolicyProvider = Provider<AcceptPrivacyPolicy>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return AcceptPrivacyPolicy(repo);
});

final getConsentStatusProvider = Provider<GetConsentStatus>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return GetConsentStatus(repo);
});
