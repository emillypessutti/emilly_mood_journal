# Prompt: Construção da Entidade MoodStatisticsEntity

## Contexto

A entidade `MoodStatisticsEntity` representa estatísticas e análises agregadas sobre os registros de humor do usuário. Calcula métricas como média de humor, distribuição por níveis, tendências e humor predominante em um período específico (semana, mês, trimestre, ano).

## Localização

- **Entity**: `lib/domain/entities/mood_statistics_entity.dart`
- **DTO**: `lib/data/dtos/mood_statistics_dto.dart`
- **Mapper**: `lib/data/mappers/mood_statistics_mapper.dart`
- **Repository Interface**: `lib/domain/repositories/mood_statistics_repository.dart` *(a implementar)*
- **Repository Implementation**: `lib/data/repositories/mood_statistics_repository_impl.dart` *(a implementar)*
- **Data Source**: `lib/data/datasources/mood_statistics_local_datasource.dart` *(a implementar)*
- **Use Cases**: `lib/domain/usecases/mood_statistics/`
  - `calculate_statistics.dart`
  - `get_statistics_by_period.dart`
  - `get_weekly_statistics.dart`
  - `get_monthly_statistics.dart`

## Estrutura da Entidade

### Campos Obrigatórios

- `userId` (String): ID do usuário (não pode ser vazio)
- `period` (Period): Período de análise (enum: week, month, quarter, year)
- `averageMood` (double): Média de humor no período (1.0 a 5.0)
- `totalEntries` (int): Total de registros no período (>= 0)
- `moodDistribution` (Map<String, int>): Distribuição de humor por nível
- `startDate` (DateTime): Data inicial do período
- `endDate` (DateTime): Data final do período

### Campos Opcionais

Nenhum campo opcional nesta entidade.

### Métodos e Getters

- `copyWith()`: Cria uma cópia da entidade com campos modificados
- `dominantMood` (getter): Calcula o humor predominante no período
- `hasEnoughData` (getter): Verifica se há dados suficientes para análise (>= 3 registros)
- `trend` (getter): Calcula tendência (positive, negative, stable)
- `periodInDays` (getter): Retorna a duração do período em dias
- `averageEntriesPerDay` (getter): Média de registros por dia

### Enum Period

Valores possíveis:
- `week`: Semana (7 dias)
- `month`: Mês (30 dias)
- `quarter`: Trimestre (90 dias)
- `year`: Ano (365 dias)

## Regras de Construção

### 1. Entity (Domain Layer)

```dart
// lib/domain/entities/mood_statistics_entity.dart
class MoodStatisticsEntity {
  final String userId;
  final Period period;
  final double averageMood;
  final int totalEntries;
  final Map<String, int> moodDistribution;
  final DateTime startDate;
  final DateTime endDate;

  MoodStatisticsEntity({
    required this.userId,
    required this.period,
    required this.averageMood,
    required this.totalEntries,
    required this.moodDistribution,
    required this.startDate,
    required this.endDate,
  })  : assert(userId.isNotEmpty, 'User ID não pode ser vazio'),
        assert(averageMood >= 1.0 && averageMood <= 5.0,
            'Média de humor deve estar entre 1.0 e 5.0'),
        assert(totalEntries >= 0, 'Total de registros não pode ser negativo'),
        assert(
            startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate),
            'Data inicial deve ser anterior ou igual à data final');

  // Getters computados
  String get dominantMood {
    if (moodDistribution.isEmpty) return 'neutral';

    var maxCount = 0;
    var dominantMoodKey = 'neutral';

    moodDistribution.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMoodKey = mood;
      }
    });

    return dominantMoodKey;
  }

  bool get hasEnoughData => totalEntries >= 3;

  String get trend {
    if (averageMood >= 4.0) return 'positive';
    if (averageMood <= 2.0) return 'negative';
    return 'stable';
  }

  int get periodInDays => endDate.difference(startDate).inDays;

  double get averageEntriesPerDay {
    final days = periodInDays > 0 ? periodInDays : 1;
    return totalEntries / days;
  }

  MoodStatisticsEntity copyWith({
    String? userId,
    Period? period,
    double? averageMood,
    int? totalEntries,
    Map<String, int>? moodDistribution,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MoodStatisticsEntity(
      userId: userId ?? this.userId,
      period: period ?? this.period,
      averageMood: averageMood ?? this.averageMood,
      totalEntries: totalEntries ?? this.totalEntries,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

enum Period {
  week('Semana', 7),
  month('Mês', 30),
  quarter('Trimestre', 90),
  year('Ano', 365);

  const Period(this.description, this.days);
  
  final String description;
  final int days;

  static Period fromString(String value) {
    return Period.values.firstWhere(
      (period) => period.name == value,
      orElse: () => throw ArgumentError('Período inválido: $value'),
    );
  }
}
```

**Regras:**
- ✅ NÃO deve ter dependências do Flutter (apenas Dart puro)
- ✅ Todos os campos devem ser `final`
- ✅ Deve implementar `copyWith()` para imutabilidade
- ✅ Validações via `assert` (userId, averageMood 1-5, totalEntries >= 0, datas)
- ✅ Getters computados para métricas derivadas

### 2. DTO (Data Layer)

```dart
// lib/data/dtos/mood_statistics_dto.dart
class MoodStatisticsDto {
  final String userId;
  final String period; // enum serializado como string
  final double averageMood;
  final int totalEntries;
  final Map<String, int> moodDistribution;
  final String startDate; // DateTime serializado como ISO8601
  final String endDate; // DateTime serializado como ISO8601

  MoodStatisticsDto({
    required this.userId,
    required this.period,
    required this.averageMood,
    required this.totalEntries,
    required this.moodDistribution,
    required this.startDate,
    required this.endDate,
  });

  factory MoodStatisticsDto.fromJson(Map<String, dynamic> json) {
    return MoodStatisticsDto(
      userId: json['userId'] as String,
      period: json['period'] as String,
      averageMood: (json['averageMood'] as num).toDouble(),
      totalEntries: json['totalEntries'] as int? ?? 0,
      moodDistribution: Map<String, int>.from(
        json['moodDistribution'] as Map? ?? {},
      ),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'period': period,
      'averageMood': averageMood,
      'totalEntries': totalEntries,
      'moodDistribution': moodDistribution,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
```

**Regras:**
- ✅ Enums devem ser serializados como strings
- ✅ Datas devem ser serializadas como strings ISO8601
- ✅ Map deve ter valor padrão vazio no `fromJson`
- ✅ `averageMood` pode vir como int ou double no JSON

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/mood_statistics_mapper.dart
import 'package:mood_journal/domain/entities/mood_statistics_entity.dart';
import 'package:mood_journal/data/dtos/mood_statistics_dto.dart';

class MoodStatisticsMapper {
  static MoodStatisticsEntity toEntity(MoodStatisticsDto dto) {
    return MoodStatisticsEntity(
      userId: dto.userId,
      period: Period.fromString(dto.period),
      averageMood: dto.averageMood,
      totalEntries: dto.totalEntries,
      moodDistribution: dto.moodDistribution,
      startDate: DateTime.parse(dto.startDate),
      endDate: DateTime.parse(dto.endDate),
    );
  }

  static MoodStatisticsDto toDto(MoodStatisticsEntity entity) {
    return MoodStatisticsDto(
      userId: entity.userId,
      period: entity.period.name,
      averageMood: entity.averageMood,
      totalEntries: entity.totalEntries,
      moodDistribution: entity.moodDistribution,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate.toIso8601String(),
    );
  }
}
```

### 4. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/mood_statistics_repository.dart
import 'package:mood_journal/domain/entities/mood_statistics_entity.dart';

abstract class MoodStatisticsRepository {
  Future<MoodStatisticsEntity> calculateStatistics({
    required String userId,
    required Period period,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<MoodStatisticsEntity> getWeeklyStatistics(String userId);
  Future<MoodStatisticsEntity> getMonthlyStatistics(String userId);
  Future<MoodStatisticsEntity> getQuarterlyStatistics(String userId);
  Future<MoodStatisticsEntity> getYearlyStatistics(String userId);
}
```

### 5. Use Case Example

```dart
// lib/domain/usecases/mood_statistics/calculate_statistics.dart
import 'package:mood_journal/domain/entities/mood_statistics_entity.dart';
import 'package:mood_journal/domain/repositories/mood_statistics_repository.dart';

class CalculateStatistics {
  final MoodStatisticsRepository repository;

  CalculateStatistics(this.repository);

  Future<MoodStatisticsEntity> call({
    required String userId,
    required Period period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.calculateStatistics(
      userId: userId,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
```

## Exemplo de Uso Completo

```dart
// Calcular estatísticas da última semana
final now = DateTime.now();
final lastWeek = now.subtract(const Duration(days: 7));

final stats = MoodStatisticsEntity(
  userId: 'user123',
  period: Period.week,
  averageMood: 4.2,
  totalEntries: 5,
  moodDistribution: {
    'veryHappy': 2,
    'happy': 2,
    'neutral': 1,
  },
  startDate: lastWeek,
  endDate: now,
);

// Analisar estatísticas
print(stats.dominantMood); // 'veryHappy' ou 'happy'
print(stats.trend); // 'positive'
print(stats.hasEnoughData); // true (5 >= 3)
print(stats.averageEntriesPerDay); // ~0.71 registros/dia
print(stats.periodInDays); // 7

// Usar no repositório
final repository = MoodStatisticsRepositoryImpl(dataSource);
final weeklyStats = await repository.getWeeklyStatistics('user123');
```

## Checklist de Implementação

- [x] Entity está em `lib/domain/entities/` sem dependências do Flutter
- [x] DTO está em `lib/data/dtos/` com serialização JSON
- [x] Mapper está em `lib/data/mappers/` com métodos `toEntity` e `toDto`
- [ ] Repository interface está em `lib/domain/repositories/`
- [ ] Repository implementation está em `lib/data/repositories/`
- [ ] Data source está em `lib/data/datasources/`
- [ ] Use cases estão em `lib/domain/usecases/mood_statistics/`
- [x] Todos os campos são `final`
- [x] Entity implementa `copyWith()`
- [x] DTO tem `fromJson` e `toJson`
- [x] Mapper trata conversões de enum e DateTime
- [x] Validações via `assert` (userId, averageMood 1-5, totalEntries >= 0, datas)
- [ ] Imports não incluem `/lib` no caminho do pacote

## Referências

- Arquitetura: Clean Architecture
- Padrão: Repository Pattern
- Serialização: JSON com ISO8601 para datas
- Imutabilidade: Todas as entidades são imutáveis
