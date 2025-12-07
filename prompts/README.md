# Prompts - Construção de Entidades

Esta pasta contém prompts detalhados para a construção e manutenção das entidades do projeto MoodJournal.

## Estrutura

- `entidades/` - Prompts específicos para cada entidade do domínio

## Como Usar

Cada arquivo contém:

- **Contexto**: Informações sobre a entidade e seu propósito
- **Estrutura Atual**: Detalhes da implementação existente
- **Regras de Construção**: Diretrizes para criar/modificar a entidade
- **Exemplos**: Código de referência e padrões a seguir
- **Checklist**: Itens a verificar ao trabalhar com a entidade

## Entidades Disponíveis

### Entidades Implementadas
1. **[DailyGoalEntity](entidades/daily_goal.md)** - Metas diárias de bem-estar
2. **[MoodEntryEntity](entidades/mood_entry.md)** - Registros de humor do usuário
3. **[MoodStatisticsEntity](entidades/mood_statistics.md)** - Estatísticas e análises de humor *(a criar)*
4. **[UserProfileEntity](entidades/user_profile.md)** - Perfil do usuário *(a criar)*

### Status de Implementação

| Entidade | Entity | DTO | Mapper | Repository | DataSource | Use Cases |
|----------|--------|-----|--------|------------|------------|-----------|
| DailyGoal | ✅ | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| MoodEntry | ✅ | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| MoodStatistics | ✅ | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| UserProfile | ✅ | ✅ | ✅ | ⏳ | ⏳ | ⏳ |

Legenda: ✅ Implementado | ⏳ A implementar | ❌ Não aplicável

## Regras Importantes

### Clean Architecture

O projeto segue Clean Architecture com a seguinte separação de camadas:

```
lib/
├── domain/              # Camada de Domínio (lógica de negócio)
│   ├── entities/        # Entidades de negócio
│   ├── repositories/    # Interfaces de repositórios
│   └── usecases/        # Casos de uso
├── data/                # Camada de Dados (implementação)
│   ├── dtos/            # Data Transfer Objects
│   ├── mappers/         # Conversores DTO ↔ Entity
│   ├── datasources/     # Fontes de dados
│   └── repositories/    # Implementação de repositórios
└── presentation/        # Camada de Apresentação (UI)
    ├── screens/         # Telas
    ├── widgets/         # Widgets reutilizáveis
    └── providers/       # Estado (Riverpod)
```

### Imports

Em Dart, imports de pacote **NÃO** devem incluir `/lib` no caminho:

✅ **Correto:**
```dart
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/data/dtos/daily_goal_dto.dart';
```

❌ **Incorreto:**
```dart
import 'package:mood_journal/lib/domain/entities/daily_goal_entity.dart';
import 'package:mood_journal/lib/data/dtos/daily_goal_dto.dart';
```

### Imutabilidade

Todas as entidades devem ser imutáveis:

- Todos os campos devem ser `final`
- Deve implementar método `copyWith()` para criar cópias modificadas
- Getters computados não devem modificar estado

### Serialização

- **Datas**: Sempre usar ISO8601 (`.toIso8601String()` e `DateTime.parse()`)
- **Enums**: Serializar como strings usando `.name` e métodos `fromString()`
- **Listas**: Sempre ter valor padrão (lista vazia) para campos opcionais
- **JSON**: DTOs devem ter `fromJson` e `toJson`

### Validações

- Usar `assert` no construtor das entidades para invariantes
- Validações específicas de domínio (ex: email válido, ID não vazio)
- Getters para validações mais complexas (ex: `isValid`, `isComplete`)

## Padrões de Nomenclatura

### Entidades (Domain)
- **Arquivo**: `[nome]_entity.dart`
- **Classe**: `[Nome]Entity`
- **Exemplo**: `daily_goal_entity.dart` → `DailyGoalEntity`

### DTOs (Data)
- **Arquivo**: `[nome]_dto.dart`
- **Classe**: `[Nome]Dto`
- **Exemplo**: `daily_goal_dto.dart` → `DailyGoalDto`

### Mappers (Data)
- **Arquivo**: `[nome]_mapper.dart`
- **Classe**: `[Nome]Mapper`
- **Métodos**: `static toEntity()`, `static toDto()`

### Repositories

**Interface (Domain):**
- **Arquivo**: `[nome]_repository.dart`
- **Classe**: `abstract class [Nome]Repository`

**Implementação (Data):**
- **Arquivo**: `[nome]_repository_impl.dart`
- **Classe**: `[Nome]RepositoryImpl implements [Nome]Repository`

### Data Sources (Data)
- **Arquivo**: `[nome]_local_datasource.dart`
- **Classe**: `abstract class [Nome]LocalDataSource`

### Use Cases (Domain)
- **Arquivo**: `[acao]_[nome].dart` (ex: `add_daily_goal.dart`)
- **Classe**: `[Acao][Nome]` (ex: `AddDailyGoal`)
- **Método**: `Future<T> call(parametros)`

## Fluxo de Desenvolvimento

1. **Definir Entity** no domínio com validações e regras de negócio
2. **Criar DTO** para serialização de dados
3. **Implementar Mapper** para conversão Entity ↔ DTO
4. **Definir Repository Interface** com operações necessárias
5. **Criar Data Source** abstrato para fonte de dados
6. **Implementar Repository** usando data source e mapper
7. **Criar Use Cases** para cada operação de negócio
8. **Configurar DI** (Dependency Injection) com Riverpod
9. **Testar** cada camada isoladamente

## Ferramentas e Comandos Úteis

### Analisar código
```bash
flutter analyze
```

### Formatar código
```bash
dart format .
```

### Executar testes
```bash
flutter test
```

### Gerar cobertura
```bash
flutter test --coverage
```

## Referências

- **Clean Architecture**: [The Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- **Repository Pattern**: Abstração da camada de dados
- **Dependency Injection**: [Riverpod](https://riverpod.dev/)
- **Serialização**: JSON com tipos primitivos e ISO8601
- **Imutabilidade**: Entidades como Value Objects

## Contribuindo

Ao adicionar uma nova entidade:

1. Crie o arquivo markdown em `prompts/entidades/[nome].md`
2. Siga o template estabelecido
3. Atualize este README.md com a nova entidade
4. Atualize a tabela de Status de Implementação
5. Implemente seguindo as regras de cada camada
