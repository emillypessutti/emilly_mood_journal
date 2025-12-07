# Prompt: Construção da Entidade MoodEntryEntity

## Contexto

A entidade `MoodEntryEntity` representa um registro de humor do usuário no aplicativo MoodJournal. É a entidade central do domínio, permitindo que os usuários registrem como se sentem em um determinado momento, com nível de humor (1-5), nota opcional e tags.

## Localização

- **Entity**: `lib/domain/entities/mood_entry_entity.dart`
- **DTO**: `lib/data/dtos/mood_entry_dto.dart`
- **Mapper**: `lib/data/mappers/mood_entry_mapper.dart`
- **Repository Interface**: `lib/domain/repositories/mood_entry_repository.dart` *(a implementar)*
- **Repository Implementation**: `lib/data/repositories/mood_entry_repository_impl.dart` *(a implementar)*
- **Data Source**: `lib/data/datasources/mood_entry_local_datasource.dart` *(a implementar)*
- **Use Cases**: `lib/domain/usecases/mood_entries/`
  - `get_mood_entry_by_id.dart`
  - `get_all_mood_entries.dart`
  - `add_mood_entry.dart`
  - `update_mood_entry.dart`
  - `delete_mood_entry.dart`
  - `get_entries_by_date_range.dart`
  - `get_today_entry.dart`

## Estrutura da Entidade

### Campos Obrigatórios

- `id` (String): Identificador único do registro (não pode ser vazio)
- `level` (MoodLevel): Nível de humor (enum: veryHappy, happy, neutral, sad, verySad)
- `timestamp` (DateTime): Data e hora do registro

### Campos Opcionais

- `note` (String?): Anotação sobre o humor (máximo 500 caracteres, padrão: null)
- `tags` (List<String>): Lista de tags associadas (padrão: lista vazia [])

### Métodos e Getters

- `copyWith()`: Cria uma cópia da entidade com campos modificados
- `isValid` (getter): Verifica se o timestamp não está no futuro
- `hasNote` (getter): Verifica se há anotação preenchida
- `intensity` (getter): Retorna a intensidade numérica do humor (1-5)

### Enum MoodLevel

Valores possíveis (do melhor para o pior):
- `veryHappy`: Muito feliz (5, 😄)
- `happy`: Feliz (4, 😊)
- `neutral`: Neutro (3, 😐)
- `sad`: Triste (2, 😔)
- `verySad`: Muito triste (1, 😢)

## Regras de Construção

### 1. Entity (Domain Layer)

```dart
// lib/domain/entities/mood_entry_entity.dart
class MoodEntryEntity {
  final String id;
  final MoodLevel level;
  final DateTime timestamp;
  final String? note;
  final List<String> tags;

  MoodEntryEntity({
    required this.id,
    required this.level,
    required this.timestamp,
    this.note,
    List<String>? tags,
  })  : tags = tags ?? [],
        assert(id.isNotEmpty, 'ID não pode ser vazio'),
        assert(note == null || note.length <= 500,
            'Nota não pode exceder 500 caracteres');

  // Getters computados
  bool get isValid => !timestamp.isAfter(DateTime.now());
  bool get hasNote => note != null && note!.isNotEmpty;
  int get intensity => level.value;

  MoodEntryEntity copyWith({
    String? id,
    MoodLevel? level,
    DateTime? timestamp,
    String? note,
    List<String>? tags,
  }) {
    return MoodEntryEntity(
      id: id ?? this.id,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}

enum MoodLevel {
  veryHappy(5, '😄', 'Muito feliz'),
  happy(4, '😊', 'Feliz'),
  neutral(3, '😐', 'Neutro'),
  sad(2, '😔', 'Triste'),
  verySad(1, '😢', 'Muito triste');

  const MoodLevel(this.value, this.emoji, this.description);
  
  final int value;
  final String emoji;
  final String description;

  static MoodLevel fromValue(int value) {
    switch (value) {
      case 5:
        return MoodLevel.veryHappy;
      case 4:
        return MoodLevel.happy;
      case 3:
        return MoodLevel.neutral;
      case 2:
        return MoodLevel.sad;
      case 1:
        return MoodLevel.verySad;
      default:
        throw ArgumentError(
            'Valor de humor inválido: $value. Deve ser entre 1 e 5.');
    }
  }

  static MoodLevel fromString(String value) {
    return MoodLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => throw ArgumentError('Tipo de humor inválido: $value'),
    );
  }
}
```

**Regras:**
- ✅ NÃO deve ter dependências do Flutter (apenas Dart puro)
- ✅ Todos os campos devem ser `final`
- ✅ Campo `tags` deve ter valor padrão (lista vazia)
- ✅ Deve implementar `copyWith()` para imutabilidade
- ✅ Validações via `assert` no construtor
- ✅ Getters computados devem ser simples e sem efeitos colaterais

### 2. DTO (Data Layer)

```dart
// lib/data/dtos/mood_entry_dto.dart
class MoodEntryDto {
  final String id;
  final String level; // enum serializado como string
  final String timestamp; // DateTime serializado como ISO8601
  final String? note;
  final List<String> tags;

  MoodEntryDto({
    required this.id,
    required this.level,
    required this.timestamp,
    this.note,
    required this.tags,
  });

  factory MoodEntryDto.fromJson(Map<String, dynamic> json) {
    return MoodEntryDto(
      id: json['id'] as String,
      level: json['level'] as String,
      timestamp: json['timestamp'] as String,
      note: json['note'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'timestamp': timestamp,
      'note': note,
      'tags': tags,
    };
  }
}
```

**Regras:**
- ✅ Enums devem ser serializados como strings (MoodLevel.name)
- ✅ Datas devem ser serializadas como strings ISO8601
- ✅ Listas devem ter valor padrão (lista vazia) no `fromJson`
- ✅ Deve ter `fromJson` e `toJson` para serialização

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/mood_entry_mapper.dart
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';
import 'package:mood_journal/data/dtos/mood_entry_dto.dart';

class MoodEntryMapper {
  static MoodEntryEntity toEntity(MoodEntryDto dto) {
    return MoodEntryEntity(
      id: dto.id,
      level: MoodLevel.fromString(dto.level),
      timestamp: DateTime.parse(dto.timestamp),
      note: dto.note,
      tags: dto.tags,
    );
  }

  static MoodEntryDto toDto(MoodEntryEntity entity) {
    return MoodEntryDto(
      id: entity.id,
      level: entity.level.name,
      timestamp: entity.timestamp.toIso8601String(),
      note: entity.note,
      tags: entity.tags,
    );
  }
}
```

**Regras:**
- ✅ Métodos devem ser `static`
- ✅ Usar `MoodLevel.fromString()` para converter string em enum
- ✅ Usar `DateTime.parse()` para converter string em DateTime
- ✅ Usar `.toIso8601String()` para converter DateTime em string

### 4. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/mood_entry_repository.dart
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';

abstract class MoodEntryRepository {
  Future<MoodEntryEntity?> getMoodEntryById(String id);
  Future<List<MoodEntryEntity>> getAllMoodEntries();
  Future<List<MoodEntryEntity>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<MoodEntryEntity?> getTodayEntry();
  Future<void> addMoodEntry(MoodEntryEntity entity);
  Future<void> updateMoodEntry(MoodEntryEntity entity);
  Future<void> deleteMoodEntry(String id);
}
```

**Regras:**
- ✅ Deve ser `abstract class`
- ✅ Retorna apenas entidades do domínio (nunca DTOs)
- ✅ Métodos devem ser `Future` para operações assíncronas
- ✅ Incluir métodos específicos do domínio (getTodayEntry, getByDateRange, etc.)

### 5. Repository Implementation (Data Layer)

```dart
// lib/data/repositories/mood_entry_repository_impl.dart
import 'package:mood_journal/domain/repositories/mood_entry_repository.dart';
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';
import 'package:mood_journal/data/datasources/mood_entry_local_datasource.dart';
import 'package:mood_journal/data/mappers/mood_entry_mapper.dart';

class MoodEntryRepositoryImpl implements MoodEntryRepository {
  final MoodEntryLocalDataSource dataSource;

  MoodEntryRepositoryImpl(this.dataSource);

  @override
  Future<MoodEntryEntity?> getMoodEntryById(String id) async {
    final dto = await dataSource.getMoodEntryById(id);
    return dto != null ? MoodEntryMapper.toEntity(dto) : null;
  }

  @override
  Future<List<MoodEntryEntity>> getAllMoodEntries() async {
    final dtos = await dataSource.getAllMoodEntries();
    return dtos.map((dto) => MoodEntryMapper.toEntity(dto)).toList();
  }

  @override
  Future<List<MoodEntryEntity>> getMoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEntries = await getAllMoodEntries();
    return allEntries.where((entry) {
      return entry.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             entry.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<MoodEntryEntity?> getTodayEntry() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final todayEntries = await getMoodEntriesByDateRange(startOfDay, endOfDay);
    return todayEntries.isNotEmpty ? todayEntries.first : null;
  }

  @override
  Future<void> addMoodEntry(MoodEntryEntity entity) async {
    final dto = MoodEntryMapper.toDto(entity);
    await dataSource.addMoodEntry(dto);
  }

  @override
  Future<void> updateMoodEntry(MoodEntryEntity entity) async {
    final dto = MoodEntryMapper.toDto(entity);
    await dataSource.updateMoodEntry(dto);
  }

  @override
  Future<void> deleteMoodEntry(String id) async {
    await dataSource.deleteMoodEntry(id);
  }
}
```

**Regras:**
- ✅ Deve implementar a interface do repositório
- ✅ Deve usar o mapper para converter DTOs em Entities
- ✅ Pode conter lógica de filtragem (ex: getByDateRange)
- ✅ Não deve conter lógica de negócio complexa

### 6. Data Source (Data Layer)

```dart
// lib/data/datasources/mood_entry_local_datasource.dart
import 'package:mood_journal/data/dtos/mood_entry_dto.dart';

abstract class MoodEntryLocalDataSource {
  Future<MoodEntryDto?> getMoodEntryById(String id);
  Future<List<MoodEntryDto>> getAllMoodEntries();
  Future<void> addMoodEntry(MoodEntryDto dto);
  Future<void> updateMoodEntry(MoodEntryDto dto);
  Future<void> deleteMoodEntry(String id);
}
```

**Regras:**
- ✅ Trabalha apenas com DTOs
- ✅ Abstrai a fonte de dados (SharedPreferences, SQLite, etc.)
- ✅ Deve ser `abstract class` para permitir diferentes implementações

### 7. Use Cases (Domain Layer)

```dart
// lib/domain/usecases/mood_entries/add_mood_entry.dart
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';
import 'package:mood_journal/domain/repositories/mood_entry_repository.dart';

class AddMoodEntry {
  final MoodEntryRepository repository;

  AddMoodEntry(this.repository);

  Future<void> call(MoodEntryEntity entity) {
    return repository.addMoodEntry(entity);
  }
}

// lib/domain/usecases/mood_entries/get_today_entry.dart
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';
import 'package:mood_journal/domain/repositories/mood_entry_repository.dart';

class GetTodayEntry {
  final MoodEntryRepository repository;

  GetTodayEntry(this.repository);

  Future<MoodEntryEntity?> call() {
    return repository.getTodayEntry();
  }
}

// lib/domain/usecases/mood_entries/get_entries_by_date_range.dart
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';
import 'package:mood_journal/domain/repositories/mood_entry_repository.dart';

class GetEntriesByDateRange {
  final MoodEntryRepository repository;

  GetEntriesByDateRange(this.repository);

  Future<List<MoodEntryEntity>> call(DateTime startDate, DateTime endDate) {
    return repository.getMoodEntriesByDateRange(startDate, endDate);
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
// Criar um novo registro de humor
final entry = MoodEntryEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  level: MoodLevel.happy,
  timestamp: DateTime.now(),
  note: 'Ótimo dia de trabalho!',
  tags: ['trabalho', 'produtivo'],
);

// Atualizar usando copyWith
final updatedEntry = entry.copyWith(
  level: MoodLevel.veryHappy,
  note: 'Ótimo dia de trabalho e recebi elogio do chefe!',
);

// Verificar propriedades
print(updatedEntry.intensity); // 5
print(updatedEntry.hasNote); // true
print(updatedEntry.isValid); // true (não está no futuro)

// Usar no repositório
final repository = MoodEntryRepositoryImpl(dataSource);
await repository.addMoodEntry(entry);

// Buscar registro de hoje
final todayEntry = await repository.getTodayEntry();

// Buscar registros da última semana
final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
final entries = await repository.getMoodEntriesByDateRange(
  sevenDaysAgo,
  DateTime.now(),
);
```

## Checklist de Implementação

Ao criar ou modificar a entidade MoodEntryEntity, verifique:

- [x] Entity está em `lib/domain/entities/` sem dependências do Flutter
- [x] DTO está em `lib/data/dtos/` com serialização JSON
- [x] Mapper está em `lib/data/mappers/` com métodos `toEntity` e `toDto`
- [ ] Repository interface está em `lib/domain/repositories/`
- [ ] Repository implementation está em `lib/data/repositories/`
- [ ] Data source está em `lib/data/datasources/`
- [ ] Use cases estão em `lib/domain/usecases/mood_entries/`
- [x] Todos os campos são `final`
- [x] Campo `tags` tem valor padrão (lista vazia)
- [x] Entity implementa `copyWith()`
- [x] DTO tem `fromJson` e `toJson`
- [x] Mapper trata conversões de enum e DateTime
- [x] Validações via `assert` no construtor (id não vazio, nota <= 500 chars)
- [ ] Imports não incluem `/lib` no caminho do pacote

## Referências

- Arquitetura: Clean Architecture
- Padrão: Repository Pattern
- Serialização: JSON com ISO8601 para datas
- Imutabilidade: Todas as entidades são imutáveis
