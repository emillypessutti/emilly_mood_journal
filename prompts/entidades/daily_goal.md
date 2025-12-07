# Prompt: Construção da Entidade DailyGoalEntity

## Contexto

A entidade `DailyGoalEntity` representa uma meta diária de bem-estar do usuário no aplicativo MoodJournal. Permite que os usuários definam e acompanhem objetivos como "registrar o humor 3 vezes", "meditar 15 minutos", etc. A entidade rastreia o progresso atual em relação ao objetivo definido.

## Localização

- **Entity**: `lib/domain/entities/daily_goal_entity.dart`
- **DTO**: `lib/data/dtos/daily_goal_dto.dart`
- **Mapper**: `lib/data/mappers/daily_goal_mapper.dart`
- **Repository Interface**: `lib/domain/repositories/daily_goal_repository.dart` *(a implementar)*
- **Repository Implementation**: `lib/data/repositories/daily_goal_repository_impl.dart` *(a implementar)*
- **Data Source**: `lib/data/datasources/daily_goal_local_datasource.dart` *(a implementar)*
- **Use Cases**: `lib/domain/usecases/daily_goals/`
  - `get_daily_goal_by_id.dart`
  - `get_all_daily_goals.dart`
  - `add_daily_goal.dart`
  - `update_daily_goal.dart`
  - `delete_daily_goal.dart`
  - `get_today_goals.dart`

## Estrutura da Entidade

### Campos Obrigatórios

- `id` (String): Identificador único da meta
- `userId` (String): ID do usuário dono da meta
- `type` (GoalType): Tipo da meta (enum: moodEntries, positiveEntries, reflection, gratitude)
- `targetValue` (int): Valor alvo a ser atingido (deve ser > 0)
- `currentValue` (int): Progresso atual (deve ser >= 0)
- `date` (DateTime): Data da meta
- `isCompleted` (bool): Se a meta foi marcada como concluída

### Campos Opcionais

Nenhum campo opcional nesta entidade.

### Métodos e Getters

- `copyWith()`: Cria uma cópia da entidade com campos modificados
- `progress` (getter): Retorna o progresso como double (0.0 a 1.0)
- `progressPercentage` (getter): Retorna o progresso em porcentagem (0 a 100)
- `isAchieved` (getter): Verifica se a meta foi atingida (currentValue >= targetValue)
- `remaining` (getter): Quantidade restante para completar a meta
- `isToday` (getter): Verifica se a meta é de hoje

### Enum GoalType

Valores possíveis:
- `moodEntries`: Registros de Humor (📝)
- `positiveEntries`: Registros Positivos (😊)
- `reflection`: Momentos de Reflexão (🧘)
- `gratitude`: Gratidão (🙏)

## Regras de Construção

### 1. Entity (Domain Layer)

```dart
// lib/domain/entities/daily_goal_entity.dart
class DailyGoalEntity {
  final String id;
  final String userId;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime date;
  final bool isCompleted;

  DailyGoalEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.date,
    required this.isCompleted,
  })  : assert(id.isNotEmpty, 'ID não pode ser vazio'),
        assert(userId.isNotEmpty, 'User ID não pode ser vazio'),
        assert(targetValue > 0, 'Valor alvo deve ser positivo'),
        assert(currentValue >= 0, 'Valor atual não pode ser negativo');

  // Getters computados
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  int get progressPercentage => (progress * 100).round();
  bool get isAchieved => currentValue >= targetValue;
  int get remaining => (targetValue - currentValue).clamp(0, targetValue);
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DailyGoalEntity copyWith({
    String? id,
    String? userId,
    GoalType? type,
    int? targetValue,
    int? currentValue,
    DateTime? date,
    bool? isCompleted,
  }) {
    return DailyGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum GoalType {
  moodEntries('Registros de Humor', '📝'),
  positiveEntries('Registros Positivos', '😊'),
  reflection('Momentos de Reflexão', '🧘'),
  gratitude('Gratidão', '🙏');

  const GoalType(this.description, this.icon);
  
  final String description;
  final String icon;

  static GoalType fromString(String value) {
    return GoalType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError('Tipo de meta inválido: $value'),
    );
  }
}
```

**Regras:**
- ✅ NÃO deve ter dependências do Flutter (apenas Dart puro)
- ✅ Todos os campos devem ser `final`
- ✅ Deve implementar `copyWith()` para imutabilidade
- ✅ Validações via `assert` no construtor
- ✅ Getters computados devem ser simples e sem efeitos colaterais

### 2. DTO (Data Layer)

```dart
// lib/data/dtos/daily_goal_dto.dart
class DailyGoalDto {
  final String id;
  final String userId;
  final String type; // enum serializado como string
  final int targetValue;
  final int currentValue;
  final String date; // DateTime serializado como ISO8601
  final bool isCompleted;

  DailyGoalDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.date,
    required this.isCompleted,
  });

  factory DailyGoalDto.fromJson(Map<String, dynamic> json) {
    return DailyGoalDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      date: json['date'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}
```

**Regras:**
- ✅ Enums devem ser serializados como strings (GoalType.name)
- ✅ Datas devem ser serializadas como strings ISO8601
- ✅ Deve ter `fromJson` e `toJson` para serialização
- ✅ Valores padrão devem ser tratados no `fromJson`

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/daily_goal_mapper.dart
class DailyGoalMapper {
  static DailyGoalEntity toEntity(DailyGoalDto dto) {
    return DailyGoalEntity(
      id: dto.id,
      userId: dto.userId,
      type: GoalType.fromString(dto.type),
      targetValue: dto.targetValue,
      currentValue: dto.currentValue,
      date: DateTime.parse(dto.date),
      isCompleted: dto.isCompleted,
    );
  }

  static DailyGoalDto toDto(DailyGoalEntity entity) {
    return DailyGoalDto(
      id: entity.id,
      userId: entity.userId,
      type: entity.type.name,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      date: entity.date.toIso8601String(),
      isCompleted: entity.isCompleted,
    );
  }
}
```

**Regras:**
- ✅ Métodos devem ser `static`
- ✅ Usar `GoalType.fromString()` para converter string em enum
- ✅ Usar `DateTime.parse()` para converter string em DateTime
- ✅ Usar `.toIso8601String()` para converter DateTime em string

### 4. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/daily_goal_repository.dart
abstract class DailyGoalRepository {
  Future<DailyGoalEntity?> getDailyGoalById(String id);
  Future<List<DailyGoalEntity>> getAllDailyGoals();
  Future<List<DailyGoalEntity>> getDailyGoalsByUserId(String userId);
  Future<List<DailyGoalEntity>> getTodayGoals(String userId);
  Future<void> addDailyGoal(DailyGoalEntity entity);
  Future<void> updateDailyGoal(DailyGoalEntity entity);
  Future<void> deleteDailyGoal(String id);
}
```

**Regras:**
- ✅ Deve ser `abstract class`
- ✅ Retorna apenas entidades do domínio (nunca DTOs)
- ✅ Métodos devem ser `Future` para operações assíncronas
- ✅ Incluir métodos específicos do domínio (getTodayGoals, etc.)

### 5. Repository Implementation (Data Layer)

```dart
// lib/data/repositories/daily_goal_repository_impl.dart
import 'package:mood_journal/domain/repositories/daily_goal_repository.dart';
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/data/datasources/daily_goal_local_datasource.dart';
import 'package:mood_journal/data/mappers/daily_goal_mapper.dart';

class DailyGoalRepositoryImpl implements DailyGoalRepository {
  final DailyGoalLocalDataSource dataSource;

  DailyGoalRepositoryImpl(this.dataSource);

  @override
  Future<DailyGoalEntity?> getDailyGoalById(String id) async {
    final dto = await dataSource.getDailyGoalById(id);
    return dto != null ? DailyGoalMapper.toEntity(dto) : null;
  }

  @override
  Future<List<DailyGoalEntity>> getAllDailyGoals() async {
    final dtos = await dataSource.getAllDailyGoals();
    return dtos.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
  }

  @override
  Future<List<DailyGoalEntity>> getDailyGoalsByUserId(String userId) async {
    final dtos = await dataSource.getDailyGoalsByUserId(userId);
    return dtos.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
  }

  @override
  Future<List<DailyGoalEntity>> getTodayGoals(String userId) async {
    final allGoals = await getDailyGoalsByUserId(userId);
    return allGoals.where((goal) => goal.isToday).toList();
  }

  @override
  Future<void> addDailyGoal(DailyGoalEntity entity) async {
    final dto = DailyGoalMapper.toDto(entity);
    await dataSource.addDailyGoal(dto);
  }

  @override
  Future<void> updateDailyGoal(DailyGoalEntity entity) async {
    final dto = DailyGoalMapper.toDto(entity);
    await dataSource.updateDailyGoal(dto);
  }

  @override
  Future<void> deleteDailyGoal(String id) async {
    await dataSource.deleteDailyGoal(id);
  }
}
```

**Regras:**
- ✅ Deve implementar a interface do repositório
- ✅ Deve usar o mapper para converter DTOs em Entities
- ✅ Deve injetar dependências via construtor
- ✅ Não deve conter lógica de negócio (apenas orquestração)

### 6. Data Source (Data Layer)

```dart
// lib/data/datasources/daily_goal_local_datasource.dart
import 'package:mood_journal/data/dtos/daily_goal_dto.dart';

abstract class DailyGoalLocalDataSource {
  Future<DailyGoalDto?> getDailyGoalById(String id);
  Future<List<DailyGoalDto>> getAllDailyGoals();
  Future<List<DailyGoalDto>> getDailyGoalsByUserId(String userId);
  Future<void> addDailyGoal(DailyGoalDto dto);
  Future<void> updateDailyGoal(DailyGoalDto dto);
  Future<void> deleteDailyGoal(String id);
}
```

**Regras:**
- ✅ Trabalha apenas com DTOs
- ✅ Abstrai a fonte de dados (SharedPreferences, SQLite, etc.)
- ✅ Deve ser `abstract class` para permitir diferentes implementações

### 7. Use Cases (Domain Layer)

```dart
// lib/domain/usecases/daily_goals/get_daily_goal_by_id.dart
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/domain/repositories/daily_goal_repository.dart';

class GetDailyGoalById {
  final DailyGoalRepository repository;

  GetDailyGoalById(this.repository);

  Future<DailyGoalEntity?> call(String id) {
    return repository.getDailyGoalById(id);
  }
}

// lib/domain/usecases/daily_goals/add_daily_goal.dart
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/domain/repositories/daily_goal_repository.dart';

class AddDailyGoal {
  final DailyGoalRepository repository;

  AddDailyGoal(this.repository);

  Future<void> call(DailyGoalEntity entity) {
    return repository.addDailyGoal(entity);
  }
}

// lib/domain/usecases/daily_goals/get_today_goals.dart
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/domain/repositories/daily_goal_repository.dart';

class GetTodayGoals {
  final DailyGoalRepository repository;

  GetTodayGoals(this.repository);

  Future<List<DailyGoalEntity>> call(String userId) {
    return repository.getTodayGoals(userId);
  }
}
```

**Regras:**
- ✅ Uma classe por caso de uso
- ✅ Método `call()` para execução
- ✅ Injeta dependências via construtor
- ✅ Retorna apenas entidades do domínio

## Exemplo de Uso Completo

```dart
// Criar uma nova meta
final goal = DailyGoalEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  userId: 'user123',
  type: GoalType.moodEntries,
  targetValue: 3,
  currentValue: 0,
  date: DateTime.now(),
  isCompleted: false,
);

// Atualizar progresso usando copyWith
final updatedGoal = goal.copyWith(
  currentValue: 2,
  isCompleted: false,
);

// Verificar progresso
print(updatedGoal.progressPercentage); // 66%
print(updatedGoal.isAchieved); // false
print(updatedGoal.remaining); // 1

// Usar no repositório
final repository = DailyGoalRepositoryImpl(dataSource);
await repository.addDailyGoal(goal);

// Buscar metas de hoje
final todayGoals = await repository.getTodayGoals('user123');
```

## Checklist de Implementação

Ao criar ou modificar a entidade DailyGoalEntity, verifique:

- [x] Entity está em `lib/domain/entities/` sem dependências do Flutter
- [x] DTO está em `lib/data/dtos/` com serialização JSON
- [x] Mapper está em `lib/data/mappers/` com métodos `toEntity` e `toDto`
- [ ] Repository interface está em `lib/domain/repositories/`
- [ ] Repository implementation está em `lib/data/repositories/`
- [ ] Data source está em `lib/data/datasources/`
- [ ] Use cases estão em `lib/domain/usecases/daily_goals/`
- [x] Todos os campos são `final`
- [x] Entity implementa `copyWith()`
- [x] DTO tem `fromJson` e `toJson`
- [x] Mapper trata conversões de enum e DateTime
- [x] Validações via `assert` no construtor
- [ ] Imports não incluem `/lib` no caminho do pacote

## Referências

- Arquitetura: Clean Architecture
- Padrão: Repository Pattern
- Serialização: JSON com ISO8601 para datas
- Imutabilidade: Todas as entidades são imutáveis
