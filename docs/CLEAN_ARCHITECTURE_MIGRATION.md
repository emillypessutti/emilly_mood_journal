# Plano de Migração para Clean Architecture

## Análise da Arquitetura Atual

### ✅ O que já está correto (Clean Architecture)

1. **Domain Layer (Parcialmente implementado)**
   - ✅ `domain/entities/`: Entidades com invariantes e regras de negócio
     - `daily_goal_entity.dart`: Entidades com validações, GoalType enum, propriedades computadas
     - `mood_entry_entity.dart`: Entidades com MoodLevel enum, validações
     - `user_profile_entity.dart`: Entity com invariantes, Email value object
     - `mood_statistics_entity.dart`: Entity de estatísticas

2. **Data Layer (Parcialmente implementado)**
   - ✅ `data/dtos/`: DTOs para serialização JSON
     - `daily_goal_dto.dart`: Espelha schema backend
     - `mood_entry_dto.dart`: Conversão JSON
   - ✅ `data/mappers/`: Conversão Entity ↔ DTO
     - `daily_goal_mapper.dart`: Conversão bidirecional sem regras de negócio

3. **Infrastructure Layer (Parcialmente implementado)**
   - ✅ `features/daily_goals/infrastructure/local/`: Interfaces e implementações
     - `daily_goal_local_dto.dart`: Interface abstrata
     - `daily_goal_local_dto_shared_prefs.dart`: Implementação com SharedPreferences
   - ✅ `features/mood_entry/infrastructure/local/`: Mesmo padrão
     - `mood_entry_local_dto.dart`: Interface abstrata
     - `mood_entry_local_dto_shared_prefs.dart`: Implementação

### ❌ Problemas Identificados (Violações Clean Architecture)

1. **Camada de Domínio Incompleta**
   - ❌ Faltam **Repository Interfaces** em `domain/repositories/`
   - ❌ Faltam **Use Cases/Interactors** em `domain/usecases/`
   - ❌ Faltam **Value Objects** (apenas Email está implementado)
   - ❌ Faltam **Domain Services** para lógica complexa

2. **Camada de Dados com Problemas**
   - ❌ `services/` com serviços estáticos (anti-padrão):
     - `preferences_service.dart`: Métodos estáticos (sem DI)
     - `mood_storage.dart`: Métodos estáticos (sem DI)
     - `profile_repository.dart`: StateNotifier (correto Riverpod, mas deveria implementar interface)
   - ❌ Faltam **Repository Implementations** explícitas em `data/repositories/`
   - ❌ Faltam **Data Sources** abstraídos em `data/datasources/`

3. **Camada de Apresentação Mal Organizada**
   - ❌ `screens/` não está modularizado por features
   - ❌ `providers/profile_provider.dart`: Apenas referencia outro provider (sem valor agregado)
   - ❌ Lógica de negócio misturada com UI (ex: `home_screen.dart` checa política)
   - ❌ Faltam **ViewModels/Controllers** separados da UI

4. **Duplicação de Modelos**
   - ❌ `models/user_profile.dart` vs `domain/entities/user_profile_entity.dart`
   - ❌ `models/mood_entry.dart` vs `domain/entities/mood_entry_entity.dart`
   - ⚠️ Models em `models/` são mais simples (sem validações), mas duplicam conceitos

5. **Falta de Dependency Injection**
   - ❌ Serviços estáticos impedem testes unitários e isolamento
   - ❌ Sem container DI (get_it ou similar)
   - ⚠️ Riverpod usado apenas para ProfileRepository (poderia ser usado para DI global)

6. **Features Inconsistentes**
   - ✅ `features/daily_goals/`: Tem infrastructure + presentation
   - ✅ `features/mood_entry/`: Tem infrastructure + presentation
   - ❌ Outras features não estão modularizadas (privacy, profile, onboarding)

---

## Estrutura Alvo (Clean Architecture Completa)

```
lib/
├── core/                           # Compartilhado entre features
│   ├── errors/                     # Classes de erro personalizadas
│   │   ├── failures.dart           # Failure classes (NetworkFailure, CacheFailure, etc.)
│   │   └── exceptions.dart         # Exception classes
│   ├── utils/                      # Utilidades gerais
│   │   ├── constants.dart
│   │   └── formatters.dart
│   └── theme/                      # (já existe)
│
├── domain/                         # Regras de negócio puras (sem dependências externas)
│   ├── entities/                   # ✅ Já existe (manter)
│   │   ├── daily_goal_entity.dart
│   │   ├── mood_entry_entity.dart
│   │   ├── user_profile_entity.dart
│   │   └── mood_statistics_entity.dart
│   ├── repositories/               # 🆕 Interfaces de repositórios (contratos)
│   │   ├── daily_goal_repository.dart
│   │   ├── mood_entry_repository.dart
│   │   ├── user_profile_repository.dart
│   │   └── preferences_repository.dart
│   ├── usecases/                   # 🆕 Casos de uso (business logic interactors)
│   │   ├── daily_goals/
│   │   │   ├── get_daily_goals.dart
│   │   │   ├── create_daily_goal.dart
│   │   │   ├── update_daily_goal_progress.dart
│   │   │   └── delete_daily_goal.dart
│   │   ├── mood_entries/
│   │   │   ├── get_mood_entries.dart
│   │   │   ├── save_mood_entry.dart
│   │   │   ├── delete_mood_entry.dart
│   │   │   └── get_mood_statistics.dart
│   │   ├── profile/
│   │   │   ├── get_user_profile.dart
│   │   │   ├── update_user_profile.dart
│   │   │   └── update_user_photo.dart
│   │   └── privacy/
│   │       ├── check_policy_acceptance.dart
│   │       ├── accept_privacy_policy.dart
│   │       └── get_consent_status.dart
│   └── value_objects/              # 🆕 Value Objects (com validação)
│       ├── email.dart              # ✅ Já existe
│       ├── user_name.dart
│       └── policy_version.dart
│
├── data/                           # Implementações concretas de repositórios e data sources
│   ├── models/                     # ✅ Renomear de dtos/ para models/ (DTOs)
│   │   ├── daily_goal_dto.dart     # ✅ Já existe
│   │   ├── mood_entry_dto.dart
│   │   └── user_profile_dto.dart   # 🆕 Criar baseado em models/user_profile.dart
│   ├── mappers/                    # ✅ Já existe (manter)
│   │   ├── daily_goal_mapper.dart
│   │   ├── mood_entry_mapper.dart
│   │   └── user_profile_mapper.dart
│   ├── repositories/               # 🆕 Implementações de domain/repositories/
│   │   ├── daily_goal_repository_impl.dart
│   │   ├── mood_entry_repository_impl.dart
│   │   ├── user_profile_repository_impl.dart
│   │   └── preferences_repository_impl.dart
│   └── datasources/                # 🆕 Data sources (local/remote)
│       ├── local/
│       │   ├── daily_goal_local_datasource.dart          # Interface
│       │   ├── daily_goal_local_datasource_impl.dart     # SharedPreferences
│       │   ├── mood_entry_local_datasource.dart
│       │   ├── mood_entry_local_datasource_impl.dart
│       │   ├── preferences_local_datasource.dart
│       │   └── preferences_local_datasource_impl.dart
│       └── remote/                 # (para futuro backend)
│           └── (vazio por enquanto)
│
├── presentation/                   # UI e lógica de apresentação
│   ├── features/
│   │   ├── daily_goals/
│   │   │   ├── pages/              # Renomear de presentation/
│   │   │   │   └── daily_goal_page.dart
│   │   │   ├── widgets/
│   │   │   │   └── daily_goal_entity_form_dialog.dart
│   │   │   └── providers/          # 🆕 Riverpod providers para essa feature
│   │   │       ├── daily_goal_provider.dart
│   │   │       └── daily_goal_state.dart
│   │   ├── mood_entry/
│   │   │   ├── pages/
│   │   │   │   └── entity_list_page.dart
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── privacy/                # 🆕 Mover screens/privacy_policy_screen.dart
│   │   │   ├── pages/
│   │   │   │   ├── privacy_policy_screen.dart
│   │   │   │   └── policy_viewer_screen.dart
│   │   │   └── providers/
│   │   │       └── privacy_provider.dart
│   │   ├── profile/                # 🆕 Mover screens/profile_*.dart
│   │   │   ├── pages/
│   │   │   │   ├── profile_edit_screen.dart
│   │   │   │   └── profile_setup_screen.dart
│   │   │   └── providers/
│   │   │       └── profile_provider.dart  # Mover de lib/providers/
│   │   ├── onboarding/             # 🆕 Mover screens/onboarding_screen.dart
│   │   │   └── pages/
│   │   │       └── onboarding_screen.dart
│   │   ├── home/                   # 🆕 Mover screens/home_screen.dart
│   │   │   ├── pages/
│   │   │   │   └── home_screen.dart
│   │   │   └── providers/
│   │   └── splash/                 # 🆕 Mover screens/splash_screen.dart
│   │       └── pages/
│   │           └── splash_screen.dart
│   ├── shared/                     # Widgets compartilhados entre features
│   │   └── widgets/                # Mover de lib/widgets/
│   └── theme/                      # (já existe em lib/theme, mover)
│
├── di/                             # 🆕 Dependency Injection setup
│   ├── injection_container.dart    # Setup de DI (Riverpod providers globais)
│   └── providers.dart              # Providers centralizados
│
└── main.dart                       # Entry point (manter, ajustar imports)
```

---

## Plano de Migração (Faseado)

### **Fase 1: Criar Estrutura de Pastas e Core**
**Objetivo:** Preparar estrutura sem quebrar o código existente.

1. Criar pastas:
   ```
   lib/core/errors/
   lib/core/utils/
   lib/domain/repositories/
   lib/domain/usecases/
   lib/domain/value_objects/
   lib/data/repositories/
   lib/data/datasources/local/
   lib/data/datasources/remote/
   lib/presentation/features/
   lib/presentation/shared/widgets/
   lib/di/
   ```

2. Criar classes de erro:
   - `core/errors/failures.dart`: Failure abstrato, CacheFailure, ValidationFailure
   - `core/errors/exceptions.dart`: CacheException, NetworkException

3. Mover `lib/theme/` para `lib/presentation/theme/`
4. Mover `lib/widgets/` para `lib/presentation/shared/widgets/`

**Comandos:**
```bash
# Criar pastas
mkdir -p lib/core/{errors,utils}
mkdir -p lib/domain/{repositories,usecases,value_objects}
mkdir -p lib/data/{repositories,datasources/local,datasources/remote}
mkdir -p lib/presentation/{features,shared/widgets,theme}
mkdir -p lib/di
```

---

### **Fase 2: Criar Repository Interfaces (Domain Layer)**
**Objetivo:** Definir contratos sem implementação.

**Arquivos a criar:**

**`domain/repositories/daily_goal_repository.dart`:**
```dart
import '../entities/daily_goal_entity.dart';

abstract class DailyGoalRepository {
  Future<List<DailyGoalEntity>> getDailyGoals();
  Future<DailyGoalEntity?> getDailyGoalById(String id);
  Future<void> saveDailyGoal(DailyGoalEntity goal);
  Future<void> updateDailyGoal(DailyGoalEntity goal);
  Future<void> deleteDailyGoal(String id);
  Future<void> clearAllGoals();
}
```

**`domain/repositories/mood_entry_repository.dart`:**
```dart
import '../entities/mood_entry_entity.dart';

abstract class MoodEntryRepository {
  Future<List<MoodEntryEntity>> getMoodEntries();
  Future<MoodEntryEntity?> getMoodEntryById(String id);
  Future<void> saveMoodEntry(MoodEntryEntity entry);
  Future<void> deleteMoodEntry(String id);
  Future<List<MoodEntryEntity>> getEntriesForDate(DateTime date);
  Future<bool> hasEntryToday();
}
```

**`domain/repositories/user_profile_repository.dart`:**
```dart
import 'dart:io';
import 'dart:typed_data';
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity?> getUserProfile();
  Future<void> updateName(String name);
  Future<void> updateEmail(String email);
  Future<void> updatePhoto(File? photoFile, {Uint8List? bytes});
  Future<void> removePhoto();
  Future<void> clearProfile();
}
```

**`domain/repositories/preferences_repository.dart`:**
```dart
abstract class PreferencesRepository {
  // LGPD / Privacy
  Future<String?> getPolicyVersionAccepted();
  Future<void> setPolicyAcceptance(String version, int timestamp);
  Future<bool> getConsentMarketing();
  Future<void> setConsentMarketing(bool consent);
  
  // App state
  Future<bool> isFirstTime();
  Future<void> setFirstTimeCompleted();
  Future<bool> getDailyGoal();
  Future<void> setDailyGoal(bool enabled);
}
```

---

### **Fase 3: Criar Use Cases (Domain Layer)**
**Objetivo:** Isolar lógica de negócio em interactors.

**Padrão de Use Case:**
```dart
// Base abstrata
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {}
```

**Exemplo: `domain/usecases/daily_goals/get_daily_goals.dart`:**
```dart
import '../../entities/daily_goal_entity.dart';
import '../../repositories/daily_goal_repository.dart';

class GetDailyGoals {
  final DailyGoalRepository repository;

  GetDailyGoals(this.repository);

  Future<List<DailyGoalEntity>> call() async {
    return await repository.getDailyGoals();
  }
}
```

**Exemplo: `domain/usecases/privacy/check_policy_acceptance.dart`:**
```dart
import '../../repositories/preferences_repository.dart';

class CheckPolicyAcceptance {
  final PreferencesRepository repository;

  CheckPolicyAcceptance(this.repository);

  Future<bool> call(String currentVersion) async {
    final acceptedVersion = await repository.getPolicyVersionAccepted();
    return acceptedVersion == currentVersion;
  }
}
```

**Lista completa de Use Cases a criar:**
- Daily Goals: GetDailyGoals, CreateDailyGoal, UpdateDailyGoalProgress, DeleteDailyGoal
- Mood Entries: GetMoodEntries, SaveMoodEntry, DeleteMoodEntry, GetMoodStatistics
- Profile: GetUserProfile, UpdateUserProfile, UpdateUserPhoto
- Privacy: CheckPolicyAcceptance, AcceptPrivacyPolicy, GetConsentStatus

---

### **Fase 4: Criar Data Sources (Data Layer)**
**Objetivo:** Abstrair SharedPreferences e preparar para backend futuro.

**Exemplo: `data/datasources/local/preferences_local_datasource.dart`:**
```dart
abstract class PreferencesLocalDataSource {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);
  Future<List<String>> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
}
```

**Implementação: `data/datasources/local/preferences_local_datasource_impl.dart`:**
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_local_datasource.dart';

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  final SharedPreferences sharedPreferences;

  PreferencesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getString(String key) async => sharedPreferences.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    await sharedPreferences.setString(key, value);
  }

  // ... outros métodos
}
```

**Substituir:** `features/*/infrastructure/local/` por data sources genéricos.

---

### **Fase 5: Criar Repository Implementations (Data Layer)**
**Objetivo:** Implementar interfaces de domain usando data sources.

**Exemplo: `data/repositories/preferences_repository_impl.dart`:**
```dart
import '../../domain/repositories/preferences_repository.dart';
import '../datasources/local/preferences_local_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource localDataSource;

  PreferencesRepositoryImpl({required this.localDataSource});

  static const _keyPolicyVersion = 'policy_version_accepted';
  static const _keyPolicyTimestamp = 'policy_timestamp';
  static const _keyConsentMarketing = 'consent_marketing';
  static const _keyFirstTime = 'first_time';
  static const _keyDailyGoal = 'daily_goal_enabled';

  @override
  Future<String?> getPolicyVersionAccepted() async {
    return await localDataSource.getString(_keyPolicyVersion);
  }

  @override
  Future<void> setPolicyAcceptance(String version, int timestamp) async {
    await localDataSource.setString(_keyPolicyVersion, version);
    await localDataSource.setInt(_keyPolicyTimestamp, timestamp);
  }

  @override
  Future<bool> getConsentMarketing() async {
    return await localDataSource.getBool(_keyConsentMarketing);
  }

  @override
  Future<void> setConsentMarketing(bool consent) async {
    await localDataSource.setBool(_keyConsentMarketing, consent);
  }

  // ... outros métodos
}
```

**Mesmo padrão para:**
- `daily_goal_repository_impl.dart`
- `mood_entry_repository_impl.dart`
- `user_profile_repository_impl.dart`

---

### **Fase 6: Setup de Dependency Injection (DI)**
**Objetivo:** Configurar providers Riverpod para injeção de dependências.

**Arquivo: `di/injection_container.dart`:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/preferences_local_datasource.dart';
import '../data/datasources/local/preferences_local_datasource_impl.dart';
import '../data/repositories/preferences_repository_impl.dart';
import '../data/repositories/daily_goal_repository_impl.dart';
import '../data/repositories/mood_entry_repository_impl.dart';
import '../data/repositories/user_profile_repository_impl.dart';

import '../domain/repositories/preferences_repository.dart';
import '../domain/repositories/daily_goal_repository.dart';
import '../domain/repositories/mood_entry_repository.dart';
import '../domain/repositories/user_profile_repository.dart';

import '../domain/usecases/privacy/check_policy_acceptance.dart';
import '../domain/usecases/privacy/accept_privacy_policy.dart';
import '../domain/usecases/daily_goals/get_daily_goals.dart';
// ... outros use cases

// ===== Data Sources =====
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final preferencesLocalDataSourceProvider = Provider<PreferencesLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesLocalDataSourceImpl(sharedPreferences: prefs);
});

// ===== Repositories =====
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final dataSource = ref.watch(preferencesLocalDataSourceProvider);
  return PreferencesRepositoryImpl(localDataSource: dataSource);
});

final dailyGoalRepositoryProvider = Provider<DailyGoalRepository>((ref) {
  final dataSource = ref.watch(dailyGoalLocalDataSourceProvider);
  return DailyGoalRepositoryImpl(localDataSource: dataSource);
});

// ... outros repositórios

// ===== Use Cases =====
final checkPolicyAcceptanceProvider = Provider<CheckPolicyAcceptance>((ref) {
  final repository = ref.watch(preferencesRepositoryProvider);
  return CheckPolicyAcceptance(repository);
});

final getDailyGoalsProvider = Provider<GetDailyGoals>((ref) {
  final repository = ref.watch(dailyGoalRepositoryProvider);
  return GetDailyGoals(repository);
});

// ... outros use cases
```

**Modificar `main.dart`:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

### **Fase 7: Refatorar Presentation Layer**
**Objetivo:** Mover screens para features e usar use cases via providers.

**Estrutura:**
```
presentation/
  features/
    privacy/
      pages/
        privacy_policy_screen.dart
      providers/
        privacy_provider.dart
        privacy_state.dart
```

**Exemplo: `presentation/features/privacy/providers/privacy_state.dart`:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'privacy_state.freezed.dart';

@freezed
class PrivacyState with _$PrivacyState {
  const factory PrivacyState({
    @Default(false) bool acceptedTerms,
    @Default(false) bool acceptedPrivacy,
    @Default(false) bool acceptedDataProcessing,
    @Default(false) bool acceptedMarketing,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PrivacyState;
}
```

**Exemplo: `presentation/features/privacy/providers/privacy_provider.dart`:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/privacy/accept_privacy_policy.dart';
import '../../../../domain/usecases/privacy/get_consent_status.dart';
import '../../../../di/injection_container.dart';
import 'privacy_state.dart';

class PrivacyNotifier extends StateNotifier<PrivacyState> {
  final AcceptPrivacyPolicy acceptPrivacyPolicyUseCase;
  final GetConsentStatus getConsentStatusUseCase;

  PrivacyNotifier({
    required this.acceptPrivacyPolicyUseCase,
    required this.getConsentStatusUseCase,
  }) : super(const PrivacyState());

  Future<void> loadConsents() async {
    state = state.copyWith(isLoading: true);
    try {
      final consents = await getConsentStatusUseCase();
      state = state.copyWith(
        acceptedTerms: consents.termsAccepted,
        acceptedPrivacy: consents.privacyAccepted,
        acceptedDataProcessing: consents.dataProcessingAccepted,
        acceptedMarketing: consents.marketingAccepted,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> saveConsents(String version) async {
    state = state.copyWith(isLoading: true);
    try {
      await acceptPrivacyPolicyUseCase(
        version: version,
        marketingConsent: state.acceptedMarketing,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void updateAcceptedTerms(bool value) {
    state = state.copyWith(acceptedTerms: value);
  }

  void updateAcceptedPrivacy(bool value) {
    state = state.copyWith(acceptedPrivacy: value);
  }

  void updateAcceptedDataProcessing(bool value) {
    state = state.copyWith(acceptedDataProcessing: value);
  }

  void updateAcceptedMarketing(bool value) {
    state = state.copyWith(acceptedMarketing: value);
  }

  void acceptAll() {
    state = state.copyWith(
      acceptedTerms: true,
      acceptedPrivacy: true,
      acceptedDataProcessing: true,
      acceptedMarketing: true,
    );
  }
}

final privacyProvider = StateNotifierProvider<PrivacyNotifier, PrivacyState>((ref) {
  final acceptUseCase = ref.watch(acceptPrivacyPolicyProvider);
  final getStatusUseCase = ref.watch(getConsentStatusProvider);
  return PrivacyNotifier(
    acceptPrivacyPolicyUseCase: acceptUseCase,
    getConsentStatusUseCase: getStatusUseCase,
  );
});
```

**Refatorar `privacy_policy_screen.dart`:**
- Substituir chamadas diretas a `PreferencesService` por `ref.watch(privacyProvider)`
- Usar `ref.read(privacyProvider.notifier).loadConsents()` no initState
- Usar `ref.read(privacyProvider.notifier).saveConsents(version)` no botão

---

### **Fase 8: Consolidar Models**
**Objetivo:** Remover duplicação entre `models/` e `domain/entities/`.

**Decisão:**
- **Manter:** `domain/entities/` (fonte da verdade)
- **Manter:** `data/dtos/` (DTOs para serialização)
- **Remover:** `models/user_profile.dart` e `models/mood_entry.dart`

**Ações:**
1. Criar `data/dtos/user_profile_dto.dart` baseado em `models/user_profile.dart`
2. Criar `data/mappers/user_profile_mapper.dart`
3. Atualizar `ProfileRepository` para usar `UserProfileEntity` ao invés de `UserProfile`
4. Deletar `models/user_profile.dart` e `models/mood_entry.dart`

---

### **Fase 9: Atualizar Features Existentes**
**Objetivo:** Aplicar Clean Architecture em `features/daily_goals/` e `features/mood_entry/`.

**Mudanças:**
1. Renomear `presentation/` para `pages/` dentro de cada feature
2. Criar `providers/` dentro de cada feature
3. Extrair lógica de negócio para use cases
4. Remover `infrastructure/local/` (substituir por data sources genéricos)

**Exemplo: Daily Goals**
- Mover `features/daily_goals/presentation/daily_goal_page.dart` → `presentation/features/daily_goals/pages/daily_goal_page.dart`
- Criar `presentation/features/daily_goals/providers/daily_goal_provider.dart`
- Usar `GetDailyGoals`, `CreateDailyGoal`, `UpdateDailyGoalProgress` use cases

---

### **Fase 10: Testes e Validação**
**Objetivo:** Garantir que a migração não quebrou funcionalidades.

1. **Testes Unitários:**
   - Testar todos os use cases com mocks de repositories
   - Testar mappers (Entity ↔ DTO)
   - Testar value objects (validações)

2. **Testes de Integração:**
   - Testar repositories com data sources mockados
   - Testar fluxos completos (salvar mood entry, criar daily goal, etc.)

3. **Testes de Widget:**
   - Testar screens/pages isoladamente
   - Testar interação com providers

4. **Testes Manuais:**
   - Fluxo LGPD (aceitar política, bloquear volta, etc.)
   - Fluxo de perfil (editar nome, foto, etc.)
   - Fluxo de daily goals (criar, editar, deletar)

---

## Checklist de Migração

### Fase 1: Estrutura ✅
- [ ] Criar pastas core/, domain/, data/, presentation/, di/
- [ ] Criar core/errors/failures.dart
- [ ] Criar core/errors/exceptions.dart
- [ ] Mover lib/theme/ → lib/presentation/theme/
- [ ] Mover lib/widgets/ → lib/presentation/shared/widgets/

### Fase 2: Repository Interfaces ✅
- [ ] Criar domain/repositories/daily_goal_repository.dart
- [ ] Criar domain/repositories/mood_entry_repository.dart
- [ ] Criar domain/repositories/user_profile_repository.dart
- [ ] Criar domain/repositories/preferences_repository.dart

### Fase 3: Use Cases ✅
- [ ] Criar base UseCase abstrato
- [ ] Criar use cases de Daily Goals (4 arquivos)
- [ ] Criar use cases de Mood Entries (4 arquivos)
- [ ] Criar use cases de Profile (3 arquivos)
- [ ] Criar use cases de Privacy (3 arquivos)

### Fase 4: Data Sources ✅
- [ ] Criar data/datasources/local/preferences_local_datasource.dart
- [ ] Criar data/datasources/local/preferences_local_datasource_impl.dart
- [ ] Criar data/datasources/local/daily_goal_local_datasource.dart
- [ ] Criar data/datasources/local/daily_goal_local_datasource_impl.dart
- [ ] Criar data/datasources/local/mood_entry_local_datasource.dart
- [ ] Criar data/datasources/local/mood_entry_local_datasource_impl.dart

### Fase 5: Repository Implementations ✅
- [ ] Criar data/repositories/preferences_repository_impl.dart
- [ ] Criar data/repositories/daily_goal_repository_impl.dart
- [ ] Criar data/repositories/mood_entry_repository_impl.dart
- [ ] Criar data/repositories/user_profile_repository_impl.dart

### Fase 6: Dependency Injection ✅
- [ ] Criar di/injection_container.dart com todos os providers
- [ ] Modificar main.dart para inicializar SharedPreferences
- [ ] Adicionar ProviderScope com overrides

### Fase 7: Refatorar Presentation ✅
- [ ] Mover screens/privacy_policy_screen.dart → presentation/features/privacy/pages/
- [ ] Mover screens/policy_viewer_screen.dart → presentation/features/privacy/pages/
- [ ] Criar presentation/features/privacy/providers/privacy_provider.dart
- [ ] Mover screens/home_screen.dart → presentation/features/home/pages/
- [ ] Mover screens/profile_*.dart → presentation/features/profile/pages/
- [ ] Criar presentation/features/profile/providers/profile_provider.dart
- [ ] Mover screens/onboarding_screen.dart → presentation/features/onboarding/pages/
- [ ] Mover screens/splash_screen.dart → presentation/features/splash/pages/

### Fase 8: Consolidar Models ✅
- [ ] Criar data/dtos/user_profile_dto.dart
- [ ] Criar data/mappers/user_profile_mapper.dart
- [ ] Atualizar ProfileRepository para usar UserProfileEntity
- [ ] Deletar models/user_profile.dart
- [ ] Deletar models/mood_entry.dart (se ainda existir)

### Fase 9: Atualizar Features ✅
- [ ] Refatorar features/daily_goals/
- [ ] Refatorar features/mood_entry/
- [ ] Criar providers/ em cada feature
- [ ] Remover infrastructure/local/ (substituir por data sources)

### Fase 10: Testes ✅
- [ ] Criar testes unitários para use cases
- [ ] Criar testes unitários para mappers
- [ ] Criar testes de integração para repositories
- [ ] Criar testes de widget para screens
- [ ] Testes manuais de fluxos completos

---

## Benefícios da Migração

1. **Testabilidade:** Use cases e repositories com interfaces facilitam testes unitários com mocks
2. **Manutenibilidade:** Separação clara de responsabilidades (UI, lógica, dados)
3. **Escalabilidade:** Adicionar backend remoto será trivial (criar data sources remote)
4. **Independência de Frameworks:** Domain layer não depende de Flutter/Riverpod
5. **Reutilização:** Use cases podem ser reutilizados em diferentes UIs (web, CLI, etc.)
6. **Dependency Rule:** Dependências apontam para dentro (domain não conhece data/presentation)

---

## Próximos Passos

1. **Aprovar este plano:** Revisar e ajustar conforme necessário
2. **Executar Fase 1:** Criar estrutura de pastas
3. **Executar Fase 2-6:** Criar camadas domain e data
4. **Executar Fase 7-9:** Refatorar presentation
5. **Executar Fase 10:** Testes e validação
6. **Documentar:** Atualizar README com nova arquitetura

---

## Perguntas para Decisão

1. **Usar freezed para state classes?** (Recomendado para immutability e copyWith)
2. **Usar dartz/fpdart para Either<Failure, Success>?** (Funcional programming style)
3. **Preferir Riverpod ou get_it para DI?** (Recomendo Riverpod por já estar no projeto)
4. **Criar DTOs para todos os entities ou só para backend?** (Recomendo só para backend)
5. **Migração incremental ou big bang?** (Recomendo incremental para não quebrar tudo)

---

**Status:** 📋 Plano criado, aguardando aprovação para execução.
